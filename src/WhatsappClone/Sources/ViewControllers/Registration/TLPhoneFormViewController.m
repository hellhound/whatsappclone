#import "Application/TLConstants.h"
#import "Categories/UIKit/UIImage+TL568h.h"
#import "Categories/NSString+TLAdditions.h"
#import "Categories/NSString+TLPhoneNumber.h"
#import "Views/TLPaddedTextField.h"
#import "Services/Controllers/Registration/TLPhoneController.h"
#import "TLPhoneFormViewController.h"
#import "TLConfirmCodeViewController.h"

enum {
    kAreaTag = -56834,
    kPhoneTag
};

@interface TLPhoneFormViewController()

@property (nonatomic, strong) TLPhoneController *service;
@property (nonatomic, weak) UITextField *areaField;
@property (nonatomic, weak) UITextField *phoneField;

// setup methods
- (UILabel *)getLabelForString:(NSString *)string size:(CGFloat)size;
- (UITextField *)getAreaField;
- (UITextField *)getPhoneField;
// Everything else
// Actions
- (void)dismissViewControllerAction;
- (void)submitPhoneAction;
@end

@implementation TLPhoneFormViewController

#pragma mark -
#pragma mark TLRegistrationBaseViewController

- (SEL)getBackActionSelector
{
    return @selector(dismissViewControllerAction);
}

- (SEL)getForwardActionSelector
{
    return @selector(submitPhoneAction);
}

- (UIResponder *)getFirstResponder
{
    // Make the keyboard appear
    return self.areaField;
}

- (CGFloat)getContainerYOriging
{
    return kTLPhoneFormViewControllerContainerYOrigin;
}

- (void)containerSetup
{
    UILabel *countryCodeLabel =
        [self getLabelForString:kTLPhoneFormViewControllerCountryCodeLabel
        size:kTLPhoneFormViewControllerCountryLabelFontSize];
    UILabel *phoneLabel =
        [self getLabelForString:kTLPhoneFormViewControllerPhoneLabel
        size:kTLPhoneFormViewControllerPhoneLabelFontSize];
    UITextField *areaTextField = [self getAreaField];
    UITextField *phoneTextField = [self getPhoneField];
    CGRect countryFrame = countryCodeLabel.frame;
    CGRect areaFrame = areaTextField.frame;
    CGRect labelFrame = phoneLabel.frame;
    CGRect phoneFrame = phoneTextField.frame;
    CGFloat y = labelFrame.size.height +
        kTLPhoneFormViewControllerLabelAndFieldsPadding;
    CGFloat x = .0;

    countryFrame.origin = CGPointMake(x, labelFrame.size.height +
        kTLPhoneFormViewControllerLabelAndCountryCodePadding);
    x += countryFrame.size.width +
        kTLPhoneFormViewControllerCountryAndAreaPadding;
    areaFrame.origin = CGPointMake(x, y);
    x += areaFrame.size.width +  kTLPhoneFormViewControllerAreaAndPhonePadding;
    phoneFrame.origin = CGPointMake(x, y);
    countryCodeLabel.frame = countryFrame;
    areaTextField.frame = areaFrame;
    phoneTextField.frame = phoneFrame;
    areaTextField.tag = kAreaTag;
    phoneTextField.tag = kPhoneTag;
    // Container conf
    [self addView:phoneLabel];
    [self addView:countryCodeLabel];
    [self addView:areaTextField];
    [self addView:phoneTextField];
    // base implementation
    [super containerSetup];
    // setting up properties
    self.areaField = areaTextField;
    self.phoneField = phoneTextField;
}

#pragma mark -
#pragma mark <UITextFieldDelegate>

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    NSString *format = kTLPhoneFormViewControllerPhoneFormat;
    NSString *newText =
        [[textField.text stringByReplacingCharactersInRange:range
        withString:string] stringRemovingFormat:format];
    NSUInteger newLength = [newText length];
    NSUInteger areaLength = kTLPhoneFormViewControllerAreaCodeLength;
    NSUInteger phoneLength = kTLPhoneFormViewControllerPhoneLength;
    NSInteger tag = textField.tag;
    NSUInteger maximumLength = tag == kAreaTag ? areaLength : phoneLength;

    if (tag == kPhoneTag && newLength == 0) {
        self.phoneField.text = @"";
        [self.phoneField resignFirstResponder];
        [self.areaField becomeFirstResponder];
    } else if (tag == kAreaTag && newLength == areaLength) {
        self.areaField.text = newText;
        [self.areaField resignFirstResponder];
        [self.phoneField becomeFirstResponder];
    } else if (tag == kAreaTag && newLength > areaLength) {
        NSString *phoneText =
            [self.phoneField.text stringRemovingFormat:format];
        
        phoneText = [phoneText stringByAppendingString:string];
        phoneText = [phoneText substringForLimit:phoneLength];
        self.phoneField.text = [phoneText stringApplyingFormat:format];
        [self.areaField resignFirstResponder];
        [self.phoneField becomeFirstResponder];
    } else {
        textField.text = [[newText substringForLimit:maximumLength]
            stringApplyingFormat:format];
    }
    return NO;
}

#pragma mark -
#pragma mark <TLTPhoneControllerDelegate>

- (void)phoneDidSendFailedPhoneWithMessage:(NSString *)errorMessage
{
        UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:kTLPhoneFormViewControllerInvalidAlertTitle
            message:errorMessage
            delegate:nil cancelButtonTitle:@"Ok"
            otherButtonTitles:nil];
        [alertView show];
}

- (void)phoneDidSendSuccessPhone
{
    TLConfirmCodeViewController *confirmFormController =
        [[TLConfirmCodeViewController alloc] initWithNibName:nil bundle:nil];

    [self.navigationController pushViewController:confirmFormController
        animated:YES];
}

#pragma mark -
#pragma mark TLPhoneFormViewController

@synthesize service;
@synthesize areaField;
@synthesize phoneField;

- (TLPhoneController *)service
{
    if (service == nil)
        service = [[TLPhoneController alloc] initWithDelegate:self];
    return service;
}

- (UILabel *)getLabelForString:(NSString *)string size:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = kTLPhoneFormViewControllerLabelFontColor;
    label.text = string;

    CGSize labelSize = [string sizeWithFont:label.font
        constrainedToSize:kTLPhoneFormViewControllerLabelConstrainedSize
        lineBreakMode:NSLineBreakByWordWrapping];

    label.frame = CGRectMake(.0, .0, labelSize.width, labelSize.height);
    return label;
}

- (UITextField *)getAreaField
{
    CGRect frame = CGRectZero;

    frame.size = kTLPhoneFormViewControllerAreaCodeSize;

    TLPaddedTextField *textField =
        [[TLPaddedTextField alloc] initWithFrame:frame];

    textField.delegate = self;
    textField.backgroundColor = TL_TEXT_FIELD_TINT;
    textField.clearsOnBeginEditing = NO;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.placeholder = kTLPhoneFormViewControllerAreaCodePlaceholder;
    textField.contentInset = kTLPhoneFormViewControllerAreaCodeContentInset;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont boldSystemFontOfSize:TL_REGISTRATION_FONT_SIZE];
    textField.text = @"";
    return textField;
}

- (UITextField *)getPhoneField
{
    CGRect frame = CGRectZero;

    frame.size = kTLPhoneFormViewControllerPhoneSize;

    TLPaddedTextField *textField =
        [[TLPaddedTextField alloc] initWithFrame:frame];

    textField.delegate = self;
    textField.backgroundColor = TL_TEXT_FIELD_TINT;
    textField.clearsOnBeginEditing = NO;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.placeholder = kTLPhoneFormViewControllerPhonePlaceholder;
    textField.contentInset = kTLPhoneFormViewControllerPhoneContentInset;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont boldSystemFontOfSize:TL_REGISTRATION_FONT_SIZE];
    textField.text = @"";
    return textField;
}

#pragma mark -
#pragma mark Actions

- (void)dismissViewControllerAction
{
    [self dismissViewControllerAnimated:(BOOL)YES completion:NULL];
}

- (void)submitPhoneAction
{
    NSString *format = kTLPhoneFormViewControllerPhoneFormat;
    NSString *phone =
        [[self.areaField.text stringByAppendingString:self.phoneField.text]
        stringRemovingFormat:format];

    if ([self.service verifyPhoneStringAndSend:phone] == NO) {
        UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:kTLPhoneFormViewControllerInvalidAlertTitle
            message:kTLPhoneFormViewControllerInvalidAlertMessage
            delegate:nil cancelButtonTitle:@"Ok"
            otherButtonTitles:nil];
        [alertView show];
    }
}
@end
