#import "Application/TLConstants.h"
#import "Categories/UIKit/UIImage+TL568h.h"
#import "Categories/NSString+TLAdditions.h"
#import "Views/TLPaddedTextField.h"
#import "TLAccountDataFormViewController.h"
#import "TLConfirmCodeViewController.h"

@interface TLConfirmCodeViewController ()

// Outlets
@property (nonatomic, weak) UITextField *codeField;
// Services
@property (nonatomic, strong) TLConfirmController *service;
// Models
@property (nonatomic, assign) BOOL isNavigationItemReady;

- (UITextField *)getConfirmationField;
- (void)confirmFormAction;
@end

@implementation TLConfirmCodeViewController

#pragma mark -
#pragma mark UIViewController

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = [super navigationItem];

    if (!self.isNavigationItemReady)
        /*TODO navItem.rightBarButtonItem.enabled = NO*/;
    return navItem;
}

#pragma mark -
#pragma mark TLRegistrationBaseViewController

- (UIResponder *)getFirstResponder
{
    // Make the keyboard appear
    return self.codeField;
}

- (CGFloat)getContainerYOriging
{
    return kTLConfirmCodeViewControllerContainerYOrigin;
}

- (void)containerSetup
{
    UITextField *field = [self getConfirmationField];
    [self addView:field];
    // base implementation
    [super containerSetup];
    self.codeField = field;
}

- (SEL)getForwardActionSelector
{
    return @selector(confirmFormAction);
}

#pragma mark -
#pragma mark <UITextFieldDelegate>

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range
        withString:string];

    NSUInteger maximumLength = kTLConfirmCodeViewControllerCodeLength;

    if ([string length] <= maximumLength)
        textField.text = [text substringForLimit:maximumLength];
    return NO;
}

#pragma mark -
#pragma mark TLConfirmCodeViewController

// Services
@synthesize service;
// Models
@synthesize isNavigationItemReady;

- (TLConfirmController *)service
{
    if (service == nil)
        service = [[TLConfirmController alloc] initWithDelegate:self];
    return service;
}

- (UITextField *)getConfirmationField
{
    CGRect frame = CGRectZero;

    frame.size = kTLConfirmCodeViewControllerCodeSize;

    TLPaddedTextField *textField =
        [[TLPaddedTextField alloc] initWithFrame:frame];

    textField.delegate = self;
    textField.backgroundColor = TL_TEXT_FIELD_TINT;
    textField.clearsOnBeginEditing = NO;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.autoresizingMask = 
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin;
    textField.placeholder = kTLConfirmCodeViewControllerCodePlaceholder;
    textField.contentInset = kTLConfirmCodeViewControllerCodeContentInset;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont boldSystemFontOfSize:TL_REGISTRATION_FONT_SIZE];
    textField.text = @"";
    return textField;
}

#pragma mark -
#pragma mark <TLConfirmControllerDelegate>

- (void)didSuccessVerificationSaved
{
    TLAccountDataFormViewController *acountDataViewController =
        [[TLAccountDataFormViewController alloc] initWithNibName:nil
            bundle:nil];
    [self.navigationController pushViewController:acountDataViewController
        animated:YES];
}

- (void)didFailedVerificationSavedWithErrorMessage:(NSString *)errorMsg
{
        UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:kTLPhoneFormViewControllerInvalidAlertTitle
            message:errorMsg
            delegate:nil cancelButtonTitle:@"Ok"
            otherButtonTitles:nil];
        [alertView show];
}

#pragma mark -
#pragma mark Actions

- (void)confirmFormAction
{
    NSString *verifyCode = self.codeField.text;
    if ([self.service isConfirmationCodeValid:verifyCode]) {
        [self.service sendVerificationCode:verifyCode];
    }
}
@end
