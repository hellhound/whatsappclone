#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Application/TLConstants.h"

#import "TLMediaInputView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MWPhotoBrowser.h"

static NSString *const kCameraImageName = @"tchat_media_camera";
static NSString *const kLocationImageName = @"tchat_media_location";
static NSString *const kCameraPhotoLibraryName = @"tchat_media_photolibrary";
static NSString *const kCameraSnapshotName = @"tchat_media_snapshot";
static NSString *const kCameraVideoChatName = @"tchat_media_videochat";
static NSString *const kCameraVideoLibraryName = @"tchat_media_videolibrary";

typedef enum {
    kCameraType,
    kPhotoType,
    kVideoType
} MediaButtonType;

@interface TLMediaInputView()

@property (nonatomic, weak) id<TLMediaInputViewDelegate> delegate;

// Controls
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *snapshotButton;
@property (nonatomic, strong) UIButton *choosePhotoButton;
@property (nonatomic, strong) UIButton *chooseVideoButton;
@property (nonatomic, strong) UIButton *shareLocationButton;
@property (nonatomic, strong) UIButton *videoChatButton;
@property (nonatomic, assign) MediaButtonType pressedButton;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) MWPhotoBrowser *photoBrowser;

- (void)setupButtons;
- (UIButton *)getDefaultButtonWithImageNamed:(NSString *)imageName;
- (void)sendSelectedImageAction;

//action
- (void)openCameraAction;
@end

@implementation TLMediaInputView

#pragma mark -
#pragma mark TLMediaInputView()

@synthesize delegate;

//controls
@synthesize cameraButton;
@synthesize snapshotButton;
@synthesize choosePhotoButton;
@synthesize chooseVideoButton;
@synthesize shareLocationButton;
@synthesize videoChatButton;
@synthesize photoBrowser;

#pragma mark -
#pragma mark TLMediaInputView

- (id)initWithDelegate:(id<TLMediaInputViewDelegate>)theDelegate
{
    CGRect frame = CGRectZero;

    frame.size = kTLTMojiInpuViewSize;
    if ((self = [super initWithFrame:frame]) != nil) {
        self.delegate = theDelegate;
        [self setupButtons];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)setupButtons
{
    self.backgroundColor = TL_MEDIA_VIEW_BACKGROUND_TINT;

    cameraButton = [self getDefaultButtonWithImageNamed:kCameraImageName];
    [cameraButton addTarget:self action:@selector(openCameraAction)
           forControlEvents:UIControlEventTouchUpInside];

    snapshotButton = [self getDefaultButtonWithImageNamed:kCameraSnapshotName];
    snapshotButton.enabled = NO;

    choosePhotoButton =
        [self getDefaultButtonWithImageNamed:kCameraPhotoLibraryName];
    [choosePhotoButton addTarget:self action:@selector(choosePhotoAction)
           forControlEvents:UIControlEventTouchUpInside];

    chooseVideoButton =
        [self getDefaultButtonWithImageNamed:kCameraVideoLibraryName];
    [chooseVideoButton addTarget:self action:@selector(chooseVideoAction)
                forControlEvents:UIControlEventTouchUpInside];

    shareLocationButton =
        [self getDefaultButtonWithImageNamed:kLocationImageName];
    shareLocationButton.enabled = NO;

    videoChatButton =
        [self getDefaultButtonWithImageNamed:kCameraVideoChatName];
    videoChatButton.enabled = NO;

    [self addSubview:cameraButton];
    [self addSubview:snapshotButton];
    [self addSubview:choosePhotoButton];
    [self addSubview:chooseVideoButton];
    [self addSubview:shareLocationButton];
    [self addSubview:videoChatButton];

    //layout
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(cameraButton,
            snapshotButton, choosePhotoButton, chooseVideoButton,
            shareLocationButton, videoChatButton);

    [cameraButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [snapshotButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [choosePhotoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chooseVideoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [shareLocationButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [videoChatButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:
            @"H:|[cameraButton]-1-"
            @"[snapshotButton(==cameraButton)]-1-"
            @"[choosePhotoButton(==cameraButton)]|" 
        options:0 metrics:nil views:viewsDict]];

    [self addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:
            @"H:|[chooseVideoButton]-1-"
            @"[shareLocationButton(==chooseVideoButton)]-1-"
            @"[videoChatButton(==chooseVideoButton)]|" 
        options:0 metrics:nil views:viewsDict]];

    [self addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:
            @"V:|-1-[cameraButton]-1-[chooseVideoButton(==cameraButton)]|" 
        options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:
            @"V:|-1-[snapshotButton]-1-"
            @"[shareLocationButton(==snapshotButton)]|" 
        options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat: 
            @"V:|-1-[choosePhotoButton]-1-"
            @"[videoChatButton(==choosePhotoButton)]|"
        options:0 metrics:nil views:viewsDict]];

}

- (UIButton *)getDefaultButtonWithImageNamed:(NSString *)imageName
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    UIImage *imageButton = [UIImage imageNamed:imageName];

    button.backgroundColor = TL_MEDIA_VIEW_DEFAULT_BUTTON_TINT;
    [button setImage:imageButton forState:UIControlStateNormal];

    return button;
}

#pragma mark -
#pragma mark Actions

- (void)openCameraAction
{
    UIImagePickerController *pickerController =
        [[UIImagePickerController alloc] init];
    self.pressedButton = kCameraType;
    if ([UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypeCamera] == YES) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.cameraDevice =
            UIImagePickerControllerCameraDeviceFront;
        pickerController.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
    } else {
        pickerController.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
    }
    pickerController.delegate = self;
    [(UIViewController *)self.delegate
        presentModalViewController:pickerController animated:YES];
    
}

- (void)chooseVideoAction
{
    UIImagePickerController *pickerController =
    [[UIImagePickerController alloc] init];
    pickerController.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.mediaTypes = 
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    pickerController.allowsEditing = YES;
    self.pressedButton = kVideoType;
    
    [(UIViewController *)self.delegate
     presentModalViewController:pickerController animated:YES];
    
}

- (void)choosePhotoAction
{
    UIImagePickerController *pickerController =
    [[UIImagePickerController alloc] init];
    pickerController.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    self.pressedButton = kPhotoType;
    
    [(UIViewController *)self.delegate
     presentModalViewController:pickerController animated:YES];
    
}

- (void)sendSelectedImageAction
{
    [self.delegate sendImage:self.selectedImage];
    self.selectedImage = nil;
    [photoBrowser dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark <UIImagePickerControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (self.pressedButton == kVideoType) {
        [viewController.navigationItem setTitle:@"Video"];
    }
}

- (void)    imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.pressedButton == kPhotoType) {
        UIImage *image =
            [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        self.selectedImage = image;
        
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Send" style:UIBarButtonItemStyleDone
            target:self action:@selector(sendSelectedImageAction)];
        photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        photoBrowser.navigationItem.rightBarButtonItem = anotherButton;
        [photoBrowser setInitialPageIndex:1];
        [picker pushViewController:photoBrowser animated:YES];
    } else {
        NSString *stringMedia = info[@"UIImagePickerControllerMediaType"];
        if ([stringMedia isEqualToString:@"public.image"]){
            [self.delegate sendImage:
                [info objectForKey:@"UIImagePickerControllerOriginalImage"]];
        } else if ([stringMedia isEqualToString:@"public.movie"]){
            [self.delegate sendVideoURL:
                [info objectForKey:@"UIImagePickerControllerMediaURL"]];
        }
        [picker dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark <MWPhotoBrowserDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser
             photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithImage: self.selectedImage];
}
@end
