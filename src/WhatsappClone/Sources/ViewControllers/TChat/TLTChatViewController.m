#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "UIImage+animatedGIF.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"

#import "Application/TLConstants.h"
#import "Views/TMojiInputView/TLTMojiCatalogDTO.h"
#import "Services/Models/TLMediaData.h"
#import "Views/TMojiInputView/TLTMojiInputView.h"
#import "Views/TLMediaInputView.h"
#import "TLTChatViewController.h"
#import "Views/TLPaddedTextField.h"

static NSString *const kTLChatViewCellId = @"TLChatViewCell";

typedef enum {
    kMessageInputViewTypeKeyboard,
    kMessageInputViewTypeTMoji,
    kMessageInputViewTypeMedia,
    kMessageInputViewTypeNone
} MessageInputViewType;

@interface TLTChatViewController()
// Outlets
@property (nonatomic, strong) TLPaddedTextField *messageField;
// Services
@property (nonatomic, strong) TLTChatController *service;
// Models
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, assign) BOOL areNavigationAndToolBarAlreadySetUp;
@property (nonatomic, strong) UIImage *myAvatar;
@property (nonatomic, strong) UIImage *buddyAvatar;

// Set-up methods
- (void)basicSetupWithBuddyAccountName:(NSString *)theAccountName
                           displayName:(NSString *)theDisplayName
                                 photo:(NSData *)thePhoto;
- (void)TMojiInputViewSetup;
- (void)mediaInputViewSetup;
- (void)overlaySetupWithUnderlyingView:(UITableView *)underlyingView;
- (UIBarButtonItem *)getBackButtonItem;
- (UIBarButtonItem *)getSettingsButtonItem;
- (UIBarButtonItem *)getAddButtonItem;
- (UIBarButtonItem *)getTMojiButtonItem;
- (UIBarButtonItem *)getMessageItem;
- (UIBarButtonItem *)getFlexibleSpaceItem;
- (UIBarButtonItem *)getSendButtonItem;
- (UITableView *)getBubbleTableView;
- (CGRect)getRectForTextField;
// Everything else
- (UIImageView *)TMojiImageViewFromURL:(NSURL *)aURL;
- (void)scrollToTheEnd;
- (void)scrollToTheEndAfter;
- (UIImage*) thumbnailImageForVideo:(NSData *)videoData atTime:(NSTimeInterval)time;
@end

@interface TLTChatViewController () // (TLTMojiModule)

// Outlets
@property (nonatomic, strong) TLHitForwardingView *overlay;
@property (nonatomic, strong) UIView *TMojiInputView;
@property (nonatomic, strong) UIView *mediaInputView;
@property (nonatomic, strong) UIButton *TMojiButton;
@property (nonatomic, strong) UIButton *mediaButton;
@property (nonatomic, strong) UIImage *TMojiButtonImage;
@property (nonatomic, strong) UIImage *keyboardButtonImage;
@property (nonatomic, strong) UIImage *mediaButtonImage;
// TMoji button states
@property (nonatomic, assign) BOOL wasTMojiButtonTapped;
@property (nonatomic, assign) BOOL wasMediaButtonTapped;
@property (nonatomic, assign) MessageInputViewType currentInputViewType;
@property (nonatomic, assign) MessageInputViewType TMojiButtonTypePressed;
@property (nonatomic, assign) BOOL isInputViewShowing;
@end

@interface TLTChatViewController (TLTMojiModule)

- (void)configureButtonsForTMojiState;
- (void)configureButtonsForMediaState;
- (void)configureButtonsForKeyboardState;
- (void)configureTMojiButton;
- (void)configureMediaButton;
- (void)switchInputView;
- (void)switchCurrentInputViewType;
- (void)adjustTableViewSizeForInputViewShowing:(BOOL)shouldShow
                                      userInfo:(NSDictionary *)userInfo;
- (void)overlayShouldShow:(BOOL)shouldShow
           withEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)resetTMojiModuleState;
- (void)dismissInputView;
@end

// TODO remove after demo!
@interface TLTChatViewController (TLFixtures)

- (NSOrderedSet *)getTMojiImagesCat1;
- (NSOrderedSet *)getTMojiImagesCat2;
- (NSOrderedSet *)getTMojiCatalogs;
- (NSOrderedSet *)getTMojiCatalogDTOs;
@end

@implementation TLTChatViewController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIApplicationDidChangeStatusBarOrientationNotification
        object:nil];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidAppear:(BOOL)animated
{
    [self scrollToTheEnd];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.service setMessagesAsRead];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UIViewController

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = super.navigationItem;

    if (!self.areNavigationAndToolBarAlreadySetUp) {
        // Assigning navigation buttons
        navItem.leftBarButtonItem = [self getBackButtonItem];
        navItem.rightBarButtonItem = [self getSettingsButtonItem];
        // Assigning toolbar items
        self.toolbarItems = @[[self getAddButtonItem],
            [self getTMojiButtonItem], [self getMessageItem],
            [self getFlexibleSpaceItem], [self getSendButtonItem]];
        self.navigationController.toolbarHidden = NO;
        self.areNavigationAndToolBarAlreadySetUp = YES;
    }
    return navItem;
}

#pragma mark -
#pragma mark <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

#pragma mark -
#pragma mark <UIBubbleTableViewDataSource>

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.service messageLogCount];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView
                       dataForRow:(NSInteger)row
{
    NSDictionary *currentMessage = [self.service messageAtIndex:row];
    NSInteger currentOwnership =
        ([currentMessage[@"ownership"] boolValue]) ?
        BubbleTypeSomeoneElse : BubbleTypeMine;

    NSString *textMessage = currentMessage[@"message"];
    NSBubbleData *bubbleData;

    bubbleData = [NSBubbleData dataWithText:textMessage
    date:currentMessage[@"date"]
    type:currentOwnership];

    if ([currentMessage[@"isTmoji"] boolValue]) {

        NSUInteger currentLength = [textMessage length];
        NSRange range = NSMakeRange(1, currentLength -2);
        NSString *imageName = [textMessage substringWithRange:range];
        NSURL *theURL = [[NSBundle mainBundle]
            URLForResource:[imageName stringByDeletingPathExtension]
            withExtension:[imageName pathExtension]];
        //check if the tmoji exists
        NSError *err;
        if ([theURL checkResourceIsReachableAndReturnError:&err] == YES) {
            UIImageView *imageView = [self TMojiImageViewFromURL:theURL];
            UIEdgeInsets insets = {5, 0, 10, 10};

            bubbleData = [NSBubbleData dataWithView:imageView
                date:currentMessage[@"date"]
                type:currentOwnership insets:insets];
            bubbleData.withBubble = NO;
        }
    }

    if ([currentMessage[@"isMedia"] boolValue]) {
        TLMediaData *mediaData= currentMessage[@"mediaData"];
        if (mediaData.mediaType == kMessageMediaPhoto) {
            UIImage *imagePhoto = [UIImage imageWithData:mediaData.data];
            bubbleData = [NSBubbleData dataWithImage:imagePhoto
                date:currentMessage[@"date"]
                type:currentOwnership];
        } else {
            UIImage *imagePhoto = [self thumbnailImageForVideo:mediaData.data
                    atTime:1];
            bubbleData = [NSBubbleData dataWithImage:imagePhoto
                date:currentMessage[@"date"]
                type:currentOwnership];
        }
    }

    if(currentOwnership == BubbleTypeMine){
        bubbleData.nickname = kTLTChatViewControllerUserNickname;
        bubbleData.avatar = self.myAvatar;
    }else{
        bubbleData.nickname = currentMessage[@"displayName"];
        bubbleData.avatar = self.buddyAvatar;
    }
    return bubbleData;
}

#pragma mark -
#pragma mark <TLTChatControllerDelegate>

- (void)controllerGotBackButtonAction:(TLTChatController *)controller
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)controllerGotTmojiButtonAction:(TLTChatController *)controller
{
    self.wasTMojiButtonTapped = YES;
    self.wasMediaButtonTapped = NO;
    [self configureTMojiButton];
    [self switchInputView];
}

- (void)controllerGotMediaButtonAction:(TLTChatController *)controller
{
    self.wasMediaButtonTapped = YES;
    self.wasTMojiButtonTapped = NO;
    [self configureMediaButton];
    [self switchInputView];
}

- (NSUInteger)controllerNeedMessageLength:(TLTChatController *)controller
{
    return [self.messageField.text length];
}

- (NSString *)controllerNeedMessageText:(TLTChatController *)controller
{
    return self.messageField.text;
}

- (NSString *)controllerNeedAccountName:(TLTChatController *)controller
{
    return self.accountName;
}

- (NSString *)controllerNeedDisplayName:(TLTChatController *)controller
{
    return self.displayName;
}

- (void)controllerDidSendMessage:(TLTChatController *)controller
{
    if (self.currentInputViewType == kMessageInputViewTypeKeyboard) {
        self.messageField.text = @"";
        [self.messageField resignFirstResponder];
    }
    [self.tableView reloadData];
    [self scrollToTheEnd];
}

- (void)controllerDidReceivedMessage:(TLTChatController *)controller
{
    [self.tableView reloadData];
    [self scrollToTheEnd];
}

- (void)controllerDidUpdateAvatar:(TLTChatController *)controller
{
    [self.tableView reloadData];
}

- (void)            controller:(TLTChatController *)controller
  keyboardWillShowWithUserInfo:(NSDictionary *)userInfo
{
    [self adjustTableViewSizeForInputViewShowing:YES userInfo:userInfo];
}

- (void)            controller:(TLTChatController *)controller
  keyboardWillHideWithUserInfo:(NSDictionary *)userInfo
{
    [self adjustTableViewSizeForInputViewShowing:NO userInfo:userInfo];
    if (self.wasTMojiButtonTapped == NO && self.wasMediaButtonTapped == NO)
        [self switchCurrentInputViewType];
}

- (void)controllerDidReceivedResignedActive:(TLTChatController *)controller
{
    [self dismissInputView];
}

#pragma mark -
#pragma mark <TLHitForwardingViewDelegate>

- (void)hitForwardingView:(TLHitForwardingView *)view
          wasHitWithPoint:(CGPoint)point
                    event:(UIEvent *)event
{
    [self dismissInputView];
}

#pragma mark -
#pragma mark TLTChatViewController

// Outlets
@synthesize messageField;
// Services
@synthesize service;
// Models
@synthesize accountName;
@synthesize displayName;
@synthesize areNavigationAndToolBarAlreadySetUp;
@synthesize myAvatar;
@synthesize buddyAvatar;

- (id)initWithBuddyAccountName:(NSString *)theAccountName
                   displayName:(NSString *)theDisplayName
                         photo:(NSData *)thePhoto
{
    if ((self = [super initWithStyle:UITableViewStylePlain]) != nil) {
        [self basicSetupWithBuddyAccountName:theAccountName
                                 displayName:theDisplayName photo:thePhoto];
        [self TMojiInputViewSetup];
        [self mediaInputViewSetup];
        [self overlaySetupWithUnderlyingView:self.tableView];
    }
    return self;
}

- (TLTChatController *)service
{
    if (service == nil)
        service = [[TLTChatController alloc] initWithDelegate:self];
    return service;
}

- (void)basicSetupWithBuddyAccountName:(NSString *)theAccountName
                           displayName:(NSString *)theDisplayName
                                 photo:(NSData *)thePhoto
{
    // controller conf
    self.accountName = theAccountName;
    self.displayName = theDisplayName;
    self.title = [theDisplayName uppercaseString];
    // table conf
    self.tableView = [self getBubbleTableView];
    // Message log conf
    [self.service populateMessagesForBuddyAccountName:theAccountName];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(scrollToTheEndAfter)
        name:UIApplicationDidChangeStatusBarOrientationNotification
        object:nil];
    // conf avatars
    self.myAvatar = nil;
    self.buddyAvatar = nil;
    self.buddyAvatar = [[UIImage alloc] initWithData:thePhoto];

    NSData *imageData = [self.service getAvatarForAccountName:theAccountName];

    if (imageData != nil) {
        self.buddyAvatar = [[UIImage alloc] initWithData:imageData];
    }
}

- (void)TMojiInputViewSetup
{
    self.TMojiInputView = [[TLTMojiInputView alloc]
        initWithCatalogDTOs:[self getTMojiCatalogDTOs] delegate:self];
    // start with keyboard innput view
    self.currentInputViewType = kMessageInputViewTypeKeyboard;
    // set as an undefined state the TMoji button
    self.TMojiButtonTypePressed = kMessageInputViewTypeNone;
}

- (void)mediaInputViewSetup
{
    self.mediaInputView = [[TLMediaInputView alloc] initWithDelegate:self];
}

- (void)overlaySetupWithUnderlyingView:(UITableView *)underlyingView
{
    TLHitForwardingView *view =
        [[TLHitForwardingView alloc] initWithUnderlyingView:self.view
        delegate:self];

    self.overlay = view;
}

- (UIBarButtonItem *)getBackButtonItem
{
    UIButton *backButton =
        [[UIButton alloc] initWithFrame:TL_BAR_BUTTON_RECT];

    [backButton setImage:[UIImage imageNamed:TL_BACK_ICON]
        forState:UIControlStateNormal];
    [backButton addTarget:self.service action:@selector(backButtonAction)
         forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (UIBarButtonItem *)getSettingsButtonItem
{
    UIButton *settingsButton =
        [[UIButton alloc] initWithFrame:TL_BAR_BUTTON_RECT];

    [settingsButton setImage:[UIImage imageNamed:TL_SETTINGS_ICON]
        forState:UIControlStateNormal];
    [settingsButton addTarget:nil action:NULL
         forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
}

- (UIBarButtonItem *)getAddButtonItem
{
    self.mediaButton = [[UIButton alloc] initWithFrame:TL_BAR_BUTTON_RECT];

    self.mediaButtonImage = [UIImage imageNamed:TL_ADD_ICON];
    [self.mediaButton setImage:self.mediaButtonImage
        forState:UIControlStateNormal];
    [self.mediaButton addTarget:self.service
        action:@selector(mediaButtonAction)
        forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:self.mediaButton];
}

- (UIBarButtonItem *)getTMojiButtonItem
{
    self.TMojiButton =
        [[UIButton alloc] initWithFrame:TL_BAR_BUTTON_RECT];
    self.TMojiButtonImage =
        [UIImage imageNamed:kTLTChatViewControllerTMojiIcon];
    self.keyboardButtonImage =
        [UIImage imageNamed:kTLTChatViewControllerKeyboardIcon];

    [self.TMojiButton setImage:self.TMojiButtonImage
        forState:UIControlStateNormal];
    [self.TMojiButton addTarget:self.service action:@selector(tmojiButtonAction)
         forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:self.TMojiButton];
}

- (UIBarButtonItem *)getMessageItem
{
    self.messageField = [[TLPaddedTextField alloc]
        initWithFrame:[self getRectForTextField]];
    self.messageField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageField.backgroundColor = [UIColor whiteColor];
    self.messageField.layer.cornerRadius = 0.0f;
    self.messageField.layer.masksToBounds = YES;
    self.messageField.layer.borderColor = [TL_TCHAT_SEND_BUTTON_TINT CGColor];
    self.messageField.layer.borderWidth = 2.0f;
    self.messageField.contentInset = kTLTChatTextContentInset;
    self.messageField.delegate = self;
    return [[UIBarButtonItem alloc] initWithCustomView:self.messageField];
}

- (UIBarButtonItem *)getFlexibleSpaceItem
{
    return [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
        target:nil action:NULL];
}

- (UIBarButtonItem *)getSendButtonItem
{
    UIButton *sendButton =
    [[UIButton alloc] initWithFrame:CGRectMake(.0, 8.0, 53., 30.)];
    
    [sendButton setImage:[UIImage imageNamed:kTLTChatViewControllerSendIcon]
               forState:UIControlStateNormal];
    [sendButton addTarget:self.service action:@selector(sendTextMessage)
        forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:sendButton];
}

- (UITableView *)getBubbleTableView
{
    UIBubbleTableView *bubbleTableView = [[UIBubbleTableView alloc]
        initWithFrame:CGRectMake(0, 55, 320, 300)
        style:UITableViewStylePlain];

    bubbleTableView.bubbleDataSource = self;
    bubbleTableView.showAvatars = YES;
    bubbleTableView.snapInterval = 43200;
    bubbleTableView.backgroundColor = [UIColor colorWithRed:230.0/255.0
        green:241.0/255.0 blue:243.0/255.0 alpha:1];
    return bubbleTableView;
}

- (CGRect)getRectForTextField
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;

    CGRect currentRect;
    if (([[UIDevice currentDevice] orientation] ==
                UIDeviceOrientationLandscapeLeft) ||
            ([[UIDevice currentDevice] orientation] == 
                UIDeviceOrientationLandscapeRight)) {

        currentRect = CGRectMake(5.0, 5.0, screenHeight - 150, 30);
    } else {
        currentRect = CGRectMake(5.0, 5.0, screenWidth - 150 , 30);
    }
    return currentRect;
}

- (void)scrollToTheEnd
{
    NSInteger cellsCount =  0;
    NSInteger sectionsCount = [self.tableView numberOfSections];
    NSInteger currentSection;
    for(currentSection = 0; currentSection < sectionsCount; currentSection++){
        cellsCount = [self.tableView numberOfRowsInSection:currentSection];
    }
    //NSInteger cellsCount = [self.service messageLogCount];
    if (cellsCount > 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: cellsCount-1
            inSection: currentSection-1];
        [self.tableView scrollToRowAtIndexPath: ipath
            atScrollPosition: UITableViewScrollPositionTop animated: NO];
    }
}
- (void)scrollToTheEndAfter
{
    [self performSelector:@selector(scrollToTheEnd) withObject:nil
        afterDelay:0.2];
}

- (UIImageView *)TMojiImageViewFromURL:(NSURL *)aURL
{

    UIImage *tmojiImage = [UIImage animatedImageWithAnimatedGIFURL:aURL
        duration:2];

    CGSize TMojiMaxSize = kTLTMojiInputViewTMojiSize;
    UIImageView *imageView = [[UIImageView alloc]
        initWithImage:tmojiImage];
    CGRect frameView = imageView.frame;
    if (frameView.size.height > TMojiMaxSize.height) {
        frameView.size.height = TMojiMaxSize.height;
    }
    if (frameView.size.width > TMojiMaxSize.width) {
        frameView.size.width = TMojiMaxSize.width;
    }
    imageView.frame = frameView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

#pragma mark -
#pragma mark <TLTMojiInputViewDelegate>

- (void)sendTmojiWithText:(NSString *)tmojiText
{
    [self.service sendTmojiImage:tmojiText];
}

#pragma mark -
#pragma mark <TLMediaInputViewDelegate>

- (void)sendImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self.service sendMediaPhoto:imageData];
}

- (void)sendVideoURL:(NSURL *)videoURL
{
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [self.service sendMediaVideo:videoData];
}

#pragma mark -
#pragma mark TLTChatViewController (TLTMojiModule)

// Outlets
@synthesize overlay;
@synthesize TMojiInputView;
@synthesize mediaInputView;
@synthesize TMojiButton;
@synthesize TMojiButtonImage;
@synthesize keyboardButtonImage;
@synthesize mediaButtonImage;
// TMoji button states
@synthesize wasTMojiButtonTapped;
@synthesize wasMediaButtonTapped;
@synthesize currentInputViewType;
@synthesize TMojiButtonTypePressed;
@synthesize isInputViewShowing;

- (void)configureButtonsForTMojiState
{
    self.TMojiButtonTypePressed = kMessageInputViewTypeTMoji;
    [self.TMojiButton setImage:self.keyboardButtonImage
        forState:UIControlStateNormal];
    [self.mediaButton setImage:self.mediaButtonImage
        forState:UIControlStateNormal];
}

- (void)configureButtonsForMediaState
{
    self.TMojiButtonTypePressed = kMessageInputViewTypeMedia;
    [self.TMojiButton setImage:self.TMojiButtonImage
        forState:UIControlStateNormal];
    [self.mediaButton setImage:self.keyboardButtonImage
        forState:UIControlStateNormal];
}

- (void)configureButtonsForKeyboardState
{
    self.TMojiButtonTypePressed = kMessageInputViewTypeKeyboard;
    [self.TMojiButton setImage:self.TMojiButtonImage
        forState:UIControlStateNormal];
    [self.mediaButton setImage:self.mediaButtonImage
        forState:UIControlStateNormal];
}

- (void)configureTMojiButton
{
    switch (self.currentInputViewType) {
        case kMessageInputViewTypeNone:
        case kMessageInputViewTypeKeyboard:
        case kMessageInputViewTypeMedia:
            [self configureButtonsForTMojiState];
            break;
        case kMessageInputViewTypeTMoji:
            [self configureButtonsForKeyboardState];
            break;
    }
}

- (void)configureMediaButton
{
    switch (self.currentInputViewType) {
        case kMessageInputViewTypeNone:
        case kMessageInputViewTypeKeyboard:
        case kMessageInputViewTypeTMoji:
            [self configureButtonsForMediaState];
            break;
        case kMessageInputViewTypeMedia:
            [self configureButtonsForKeyboardState];
            break;
    }
}

- (void)switchInputView
{
    UIView *inputView;
    switch (self.TMojiButtonTypePressed) {
        case kMessageInputViewTypeNone:
        case kMessageInputViewTypeKeyboard:
            inputView = nil;
            break;
        case kMessageInputViewTypeMedia:
            inputView = self.mediaInputView;
            break;
        case kMessageInputViewTypeTMoji:
            inputView = self.TMojiInputView;
            break;
    }

    if (self.isInputViewShowing) {
        [self.messageField resignFirstResponder];
        self.messageField.inputView = inputView;
    } else {
        self.messageField.inputView = inputView;
        [self.messageField becomeFirstResponder];
    }
}

- (void)switchCurrentInputViewType
{
    if (self.wasTMojiButtonTapped) {
        if (self.TMojiButtonTypePressed == kMessageInputViewTypeNone) {
            self.currentInputViewType = kMessageInputViewTypeKeyboard;
        } else if (self.currentInputViewType == kMessageInputViewTypeKeyboard ||
                   self.currentInputViewType == kMessageInputViewTypeMedia) {
            self.currentInputViewType = kMessageInputViewTypeTMoji;
        } else {
            self.currentInputViewType = kMessageInputViewTypeKeyboard;
        }
    }
    
    if (self.wasMediaButtonTapped) {
        if (self.TMojiButtonTypePressed == kMessageInputViewTypeNone) {
            self.currentInputViewType = kMessageInputViewTypeKeyboard;
        } else if (self.currentInputViewType == kMessageInputViewTypeKeyboard ||
                   self.currentInputViewType == kMessageInputViewTypeTMoji) {
            self.currentInputViewType = kMessageInputViewTypeMedia;
        } else {
            self.currentInputViewType = kMessageInputViewTypeKeyboard;
        }
    }

}

- (void)adjustTableViewSizeForInputViewShowing:(BOOL)shouldShow
                                      userInfo:(NSDictionary *)userInfo
{
    NSTimeInterval animationDuration = .25f;
    CGSize inputViewSize = [self.tableView convertRect:
        [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]
        fromView:nil].size;
    UIToolbar *toolbar = self.navigationController.toolbar;

    [UIView animateWithDuration:animationDuration animations:
    ^{
        toolbar.frame = CGRectOffset(toolbar.frame, .0,
            shouldShow ? -inputViewSize.height : inputViewSize.height);
    } completion:
    ^(BOOL finished) {
        UIApplication *app = [UIApplication sharedApplication];
        CGSize statusSize = app.statusBarFrame.size;
        CGSize navBarSize = self.navigationController.navigationBar.bounds.size;
        CGSize toolbarSize = toolbar.bounds.size;
        UIEdgeInsets contentInsets =
            UIEdgeInsetsMake(.0, .0,
                    shouldShow ? inputViewSize.height + toolbarSize.height : .0,
                    .0);
        UIEdgeInsets edgeInsetsForOverlay =
            UIEdgeInsetsMake(statusSize.height + navBarSize.height, .0,
            inputViewSize.height, .0);

        // Adjust insets
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        // Show overlay
        [self overlayShouldShow:shouldShow withEdgeInsets:edgeInsetsForOverlay];
        // Inform that the input view is showing or hiding
        self.isInputViewShowing = shouldShow;
        // Switch the current input view type
        [self switchCurrentInputViewType];
        if ((self.wasTMojiButtonTapped || self.wasMediaButtonTapped) &&
                !self.isInputViewShowing)
            [self.messageField becomeFirstResponder];
        self.wasTMojiButtonTapped = NO;
        self.wasMediaButtonTapped = NO;
        [self scrollToTheEnd];
    }];
}

- (void)overlayShouldShow:(BOOL)shouldShow
           withEdgeInsets:(UIEdgeInsets)edgeInsets
{
    // Show/hide the overlay
    if (shouldShow) {
        [self.overlay showWithEdgeInsets:edgeInsets
            orientation:self.interfaceOrientation];
    } else {
        [self.overlay hide];
    }
}

- (void)resetTMojiModuleState
{
    self.messageField.inputView = nil;
    self.wasTMojiButtonTapped = NO;
    self.currentInputViewType = kMessageInputViewTypeTMoji;
    [self configureButtonsForKeyboardState];
    self.currentInputViewType = kMessageInputViewTypeKeyboard;
    self.TMojiButtonTypePressed = kMessageInputViewTypeNone;
}

- (void)dismissInputView
{
    [self.messageField resignFirstResponder];
    [self resetTMojiModuleState];
}

#pragma mark -
#pragma mark TLTChatViewController (TLFixtures)

// TODO: Remove after demo
- (NSOrderedSet *)getTMojiImagesCat1
{
    NSString *imageDirectoryPath = [[NSBundle mainBundle] bundlePath];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"self like[c] 'cat1-th_*.gif'"];
    NSArray *imagePaths = [[[NSFileManager defaultManager]
        contentsOfDirectoryAtPath:imageDirectoryPath error:NULL]
        filteredArrayUsingPredicate:predicate];
    NSMutableOrderedSet *images = [NSMutableOrderedSet orderedSet];

    for (NSString *imagePath in imagePaths) {
        [images addObject:imagePath];
    }
    return images;
}

// TODO: Remove after demo
- (NSOrderedSet *)getTMojiImagesCat2
{
    NSString *imageDirectoryPath = [[NSBundle mainBundle] bundlePath];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"self like[c] 'cat2-th_*.gif'"];
    NSArray *imagePaths = [[[NSFileManager defaultManager]
        contentsOfDirectoryAtPath:imageDirectoryPath error:NULL]
        filteredArrayUsingPredicate:predicate];
    NSMutableOrderedSet *images = [NSMutableOrderedSet orderedSet];

    for (NSString *imagePath in imagePaths) {
        [images addObject:imagePath];
    }
    return images;
}

// TODO: Remove after demo
- (NSOrderedSet *)getTMojiCatalogs
{
    NSString *imageDirectoryPath = [[NSBundle mainBundle] bundlePath];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:
        @"self like[c] 'cat-*.png' and not self like[c] '*2x*'"];
    NSArray *imagePaths = [[[NSFileManager defaultManager]
        contentsOfDirectoryAtPath:imageDirectoryPath error:NULL]
        filteredArrayUsingPredicate:predicate];
    NSMutableOrderedSet *images = [NSMutableOrderedSet orderedSet];

    for (NSString *imagePath in imagePaths) {
        NSString *imageNamed =
            [imagePath stringByReplacingOccurrencesOfString:@".png"
            withString:@""];
        [images addObject:[UIImage imageNamed:imageNamed]];
    }
    return images;
}

// TODO: Remove after demo
- (NSOrderedSet *)getTMojiCatalogDTOs
{
    NSOrderedSet *catalogs = [self getTMojiCatalogs];
    NSOrderedSet *imagesCat1 = [self getTMojiImagesCat1];
    NSOrderedSet *imagesCat2 = [self getTMojiImagesCat2];

    NSMutableOrderedSet *dtos = [NSMutableOrderedSet orderedSet];
    BOOL alternate = YES;

    for (UIImage *catalog in catalogs) {
        TLTMojiCatalogDTO *dto = [[TLTMojiCatalogDTO alloc] init];

        dto.catalogIcon = [catalog copy];
        if (alternate) {
            [dto SetTMojiFilenames:[imagesCat1 copy]];
        } else {
            [dto SetTMojiFilenames:[imagesCat2 copy]];
        }
        [dtos addObject:dto];
        alternate = !alternate;
    }
    return dtos;
}

- (UIImage*) thumbnailImageForVideo:(NSData *)videoData atTime:(NSTimeInterval)time {
    NSString *filePath = [NSTemporaryDirectory()
        stringByAppendingPathComponent:@"videoTemp.mp4"];
    NSURL *tempURL = [NSURL fileURLWithPath:filePath];
    [videoData writeToURL:tempURL atomically:YES];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:tempURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}
@end
