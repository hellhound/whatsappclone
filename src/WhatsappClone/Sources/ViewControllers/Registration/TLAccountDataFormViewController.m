#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "UIImage+Resize.h"

#import "Application/TLAppDelegate.h"
#import "Application/TLConstants.h"
#import "Views/TLPaddedTextField.h"
#import "Services/Controllers/Registration/TLAccountDataController.h"
#import "TLAccountDataFormViewController.h"

#define kUILogoRect CGRectMake(.0, .0, 100, 50)
#define kUIPictureRect CGRectMake(.0, .0, 200, 100)
#define kUIFormSpacer 20.
#define kUIButtonImageSize 60.

@interface TLAccountDataFormViewController()

// Outlets
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIImage *photoImage;
@property (nonatomic, weak) UIButton *photoButton;
@property (nonatomic, weak) UITextField *firstNameField;
@property (nonatomic, weak) UITextField *lastNameField;
@property (nonatomic, assign) CGSize kbSize;

// Services
@property (nonatomic, strong) TLAccountDataController *service;

@property (nonatomic, assign) BOOL isPhotoGiven;

//setup methods
- (UILabel *)getDataImageLabel;
- (UIButton *)getPhotoButton;
- (UIImage *)getPhotoImage;
- (UITextField *)getBasicTextField;
- (UITextField *)getFirstNameField;
- (UITextField *)getLastNameField;

//Other
- (void)keyboardDidShowNotification:(NSNotification*)kbNotification;
- (void)keyboardWillHideNotification:(NSNotification*)aNotification;

- (void)activeNextButton;
- (void)scrollToFirstResponder;

//actions
- (void)pickPhotoAction;
- (void)doneButtonAction:(id)textField;
- (void)submitDataAction;

//notifications
@end

@implementation TLAccountDataFormViewController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIKeyboardDidShowNotification
        object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIKeyboardWillHideNotification
        object:nil];
}

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{

    if ((self = [super initWithNibName:nibName bundle:nibBundle]) != nil) {
        self.isPhotoGiven = NO;
        self.kbSize = CGSizeZero;

        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(keyboardDidShowNotification:)
            name:UIKeyboardDidShowNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(keyboardWillHideNotification:)
            name:UIKeyboardWillHideNotification
            object:nil];
    }
    return self;
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = super.navigationItem;

    if (navItem != nil) {
        navItem.leftBarButtonItem = nil;
        navItem.hidesBackButton = YES;
    }
    return navItem;
}

#pragma mark -
#pragma mark TLRegistrationBaseViewController
- (CGFloat)getContainerYOriging
{
    return .1;
}

- (void)containerSetup
{
    UIView *container = [[UIView alloc] initWithFrame:self.view.frame];

    //container.autoresizingMask = UIViewAutoresizingFlexibleWidth
        //| UIViewAutoresizingFlexibleHeight;

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.contentSize=container.frame.size;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView addSubview:container];

    UILabel *dataLabel = [self getDataImageLabel];
    [dataLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [container addSubview:dataLabel];

    photoButton = [self getPhotoButton];
    [photoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [container addSubview:photoButton];

    firstNameField = [self getFirstNameField];
    [firstNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [container addSubview:firstNameField];

    lastNameField = [self getLastNameField];
    [lastNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [container addSubview:lastNameField];

    [self activeNextButton];



    //layout
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(scrollView,
            dataLabel, photoButton, firstNameField, lastNameField);

    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:@"H:|[scrollView]|" 
        options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:@"V:|[scrollView]|" 
        options:0 metrics:nil views:viewsDict]];


    NSString *visualLayoutDataLabelH = @"H:|[dataLabel]|"; 
    [container addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:visualLayoutDataLabelH 
        options:0 metrics:0 views:viewsDict]];

    NSString *visualLayoutPhotoButtonH = [NSString stringWithFormat:
        @"[photoButton(==%f)]",kTLPhotoButtomSideSize]; 
    [container addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat: visualLayoutPhotoButtonH
        options:0 metrics:nil views:viewsDict]];
    [container addConstraint:[NSLayoutConstraint 
        constraintWithItem:photoButton
        attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual
        toItem:container
        attribute:NSLayoutAttributeCenterX
        multiplier:1.
        constant:.0]];

    NSString *visualLayoutFirstNameFieldH = [NSString stringWithFormat:
        @"H:|-%f-[firstNameField]-%f-|", kTLTextFieldHorizontalMargins,
        kTLTextFieldHorizontalMargins]; 
    [container addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat: visualLayoutFirstNameFieldH
        options:0 metrics:nil views:viewsDict]];

    NSString *visualLayoutLastNameFieldH = [NSString stringWithFormat:
        @"H:|-%f-[lastNameField]-%f-|", kTLTextFieldHorizontalMargins,
        kTLTextFieldHorizontalMargins]; 
    [container addConstraints:[NSLayoutConstraint 
        constraintsWithVisualFormat:visualLayoutLastNameFieldH 
        options:0 metrics:nil views:viewsDict]];


    NSString *visualLayoutVertical = [NSString stringWithFormat:
        @"V:|-%f-[dataLabel(==%f)]"
        @"-%f-[photoButton(==%f)]"
        @"-%f-[firstNameField(==%f)]" 
        @"-%f-[lastNameField(==%f)]->=50-|", 
        kTLVerticalToDataLabelMagin, kTLVerticalToDataLabelSize,
        kTLVerticalToPhotoButtonMagin, kTLPhotoButtomSideSize,
        kTLVerticalToFirstNameFieldMagin, kTLVerticalToFirstNameFieldSize,
        kTLVerticalToLastNameFieldMagin, kTLVerticalToLastNameFieldSize];

    [container addConstraints:[NSLayoutConstraint 
    constraintsWithVisualFormat:visualLayoutVertical
        options:0 metrics:0 views:viewsDict]];
}

- (CGRect)getContainerBounds
{
    return self.view.bounds;
}

- (SEL)getForwardActionSelector
{
    return @selector(submitDataAction);
}

#pragma mark -
#pragma mark TLAccountDataFormViewController

@synthesize photoImage;
@synthesize photoButton;
@synthesize firstNameField;
@synthesize lastNameField;
@synthesize isPhotoGiven;
@synthesize scrollView;
@synthesize kbSize;
// Services
@synthesize service;

- (TLAccountDataController *)service
{
    if (service == nil)
        service = [[TLAccountDataController alloc] initWithDelegate:self];
    return service;
}

- (UILabel *)getDataImageLabel
{
    UILabel *imageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *customFont = [UIFont fontWithName:kTLProfileAccountLabelFontName
        size:kTLProfileAccountLabelFontSize];

    imageLabel.text = kTLProfileAccountLabelText;
    imageLabel.font = customFont;
    imageLabel.textColor = kTLProfileAccountLabelColor;
    imageLabel.backgroundColor = [UIColor clearColor];
    imageLabel.textAlignment = NSTextAlignmentCenter;
    return imageLabel;
}

- (UIButton *)getPhotoButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[self getPhotoImage]
        forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickPhotoAction)
        forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImage *)getPhotoImage
{
    return [UIImage imageNamed:@"take_profile_picture"];
}

- (UITextField *)getBasicTextField
{
    TLPaddedTextField *textField =
        [[TLPaddedTextField alloc] initWithFrame:CGRectZero];
    textField.backgroundColor = TL_TEXT_FIELD_TINT;
    textField.clearsOnBeginEditing = NO;
    textField.contentInset = kTLAccountDataFormViewControllerTextContentInset;
    textField.font = [UIFont boldSystemFontOfSize:TL_REGISTRATION_FONT_SIZE];
    textField.text = @"";
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.returnKeyType = UIReturnKeyDone;
    [textField addTarget:self action:@selector(doneButtonAction:)
        forControlEvents:UIControlEventEditingDidEndOnExit];
    return textField;
}

- (UITextField *)getFirstNameField
{
    UITextField *textField = [self getBasicTextField];
    textField.placeholder =
        kTLAccountDataFormViewControllerFirstNamePlaceholder;
    textField.delegate = self;
    return textField;
}

- (UITextField *)getLastNameField
{
    UITextField *textField = [self getBasicTextField];
    textField.placeholder =
        kTLAccountDataFormViewControllerLastNamePlaceholder;
    textField.delegate = self;
    return textField;
}

- (void)keyboardDidShowNotification:(NSNotification*)kbNotification
{
    NSDictionary* info = kbNotification.userInfo;
    kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
    UIEdgeInsets contentInsets =
        UIEdgeInsetsMake(.0, .0, kbSize.height, .0);

    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

    [self scrollToFirstResponder];
}
 
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHideNotification:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)activeNextButton
{
    NSUInteger firstNameLength = [firstNameField.text length];
    NSUInteger lastNameLength = [lastNameField.text length];
    if (self.isPhotoGiven && firstNameLength > 0 && lastNameLength > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)scrollToFirstResponder
{
    //animation and scroll
    UIView *firstResponderView = nil;
    if ([firstNameField isFirstResponder]) {
        firstResponderView = firstNameField;
    } else {
        firstResponderView = lastNameField;
    }

    CGRect aRect = self.view.frame;
    CGPoint aPoint = firstResponderView.frame.origin;
    UIEdgeInsets insets = kTLAccountDataFormViewControllerTextContentInset;
    aPoint.y += firstResponderView.frame.size.height + insets.top +
        insets.bottom;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, aPoint) ) {
        CGPoint scrollPoint =
            CGPointMake(0.0, aPoint.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

#pragma mark -
#pragma mark Actions

- (void)pickPhotoAction
{
    UIImagePickerController *pickerController =
        [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypeCamera] == YES) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.cameraDevice =
            UIImagePickerControllerCameraDeviceFront;
    } else {
        pickerController.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
    }
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    [self presentModalViewController:pickerController animated:YES];
}

- (void)doneButtonAction:(id)textField
{
    if ([firstNameField.text length] == 0 && textField != firstNameField) {
        [firstNameField becomeFirstResponder];
    } else if ([lastNameField.text length] == 0) {
        [lastNameField becomeFirstResponder];
        [self scrollToFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
}

- (void)submitDataAction
{
    NSString *firstName = self.firstNameField.text;
    NSString *lastName = self.lastNameField.text;
    NSData *photo = UIImagePNGRepresentation(self.photoImage);
    [self.service updateAccountWithFirstName:firstName lastName:lastName
        photo:photo];
}

#pragma mark -
#pragma mark Actions

- (void)didAcountSavedSuccessFullyNotification
{
    [self dismissViewControllerAnimated:(BOOL)YES completion:NULL];
    TLAppDelegate *delegate =
        (TLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate didCompleteRegistrationProcess];
}

#pragma mark -
#pragma mark <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField
        shouldChangeCharactersInRange:(NSRange)range
        replacementString:(NSString *)string
{
    if (![string isEqualToString:@"\n"]) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range
            withString:string];

        NSUInteger maximumLength = kTLAccountDataFormTextFieldMaxSize;

        if ([text length] <= maximumLength)
            textField.text = [text capitalizedString];
        [self activeNextButton];
        return NO;
    }
    [self activeNextButton];
    return YES;
}


#pragma mark -
#pragma mark <UIImagePickerControllerDelegate>

- (void)    imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *preImage = info[UIImagePickerControllerEditedImage];
    CGSize newSIze = CGSizeMake(150, 150);
    self.photoImage = [preImage resizedImage:newSIze interpolationQuality:1];
    [self.photoButton setImage:self.photoImage forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
    self.isPhotoGiven = YES;
    [firstNameField becomeFirstResponder];
    [self activeNextButton];
}

@end
