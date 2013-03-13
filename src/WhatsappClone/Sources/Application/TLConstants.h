// Themes and colors
#define TL_MAIN_TINT [UIColor colorWithRed:70. / 255. green:205. / 255. \
    blue:229. / 255. alpha:1.]
#define TL_TEXT_FIELD_TINT [UIColor whiteColor]
#define TL_TCHAT_SEND_BUTTON_TINT [UIColor colorWithRed:41. /255. \
    green:173. /255. blue:197. /255. alpha:1.]
#define TL_PAGE_INDICATOR_TINT [UIColor colorWithRed:212. / 255. \
    green:212. / 255. blue:212. / 255. alpha:1.]
#define TL_TMOJI_INPUT_BACKGROUND_TINT [UIColor whiteColor]
#define TL_TMOJI_CATEGORY_BAR_BACKGROUND_TINT [UIColor colorWithRed:70. / 255. \
    green:205. / 255. blue:229. / 255. alpha:1.]
#define TL_TMOJI_CATEGORY_DEFAULT_BUTTON_TINT [UIColor colorWithRed:41. /255. \
    green:173. /255. blue:197. /255. alpha:1.]
#define TL_TMOJI_CATEGORY_PRESSED_BUTTON_TINT [UIColor whiteColor]
#define TL_MEDIA_VIEW_BACKGROUND_TINT [UIColor colorWithRed:70. / 255. \
    green:205. / 255. blue:229. / 255. alpha:1.]
#define TL_MEDIA_VIEW_DEFAULT_BUTTON_TINT [UIColor colorWithRed:41. /255. \
    green:173. /255. blue:197. /255. alpha:1.]
#define TL_LOGO_FILE_NAME @"whatsappclone-logo"
#define TL_FORWARD_ICON @"forward"
#define TL_BACK_ICON @"back"
#define TL_SETTINGS_ICON @"settings"
#define TL_ADD_ICON @"add"
#define TL_BAR_BUTTON_RECT CGRectMake(.0, .0, 25., 25.)
#define TL_REGISTRATION_FONT_SIZE 12.

// Notifications
#define kTLSendMessageNotification @"TLSendMessageNotification"
#define kTLMessageProcessedNotification @"TLMessageProcessedNotification"
#define kTLProtocolLogoutNotification @"TLProtocolLogoutNotification"
#define kTLProtocolLoginFailNotification @"TLProtocolLoginFailNotification"
#define kTLProtocolLoginSuccessNotification \
    @"TLProtocolLoginSuccessNotification"
#define kTLMessageReceivedNotification @"TLMessageReceivedNotification"
#define kTLNewMessageNotification @"TLNewMessageNotification"
#define kTLStatusUpdateNotification @"TLStatusUpdateNotification"
#define kTLProtocolDisconnectNotification @"TLProtocolDisconnectNotification"
#define kTLRosterDidPopulateNotification @"TLRosterDidPopulateNotification"
#define kTLProtocolVcardSuccessSaveNotification \
    @"TLProtocolVcardSuccessSaveNotification"
#define kTLDidBuddyVCardUpdatedNotification \
    @"TLDidBuddyVCardUpdatedNotification"

// TLAccountRegistrationViewController constants
#define kTLAccountRegistrationViewBackgroundImage @"create_account_bg"
#define kTLAccountRegistrationViewButtonImage @"create_account_button"
#define kTLAccountRegistrationViewButtonOriginY 327.

// TLPhoneFormViewController constants
#define kTLPhoneFormViewControllerBackgroundImage @"phone_form_background"
#define kTLPhoneFormViewControllerDoneButtonLabel @"Done"
#define kTLPhoneFormViewControllerLabelConstrainedSize \
    CGSizeMake(300., CGFLOAT_MAX)
#define kTLPhoneFormViewControllerAreaCodeSize CGSizeMake(70., 32.)
#define kTLPhoneFormViewControllerPhoneSize CGSizeMake(116., 32.)
#define kTLPhoneFormViewControllerAreaCodeContentInset \
    UIEdgeInsetsMake(10., 7., 12., 7.)
#define kTLPhoneFormViewControllerPhoneContentInset \
    UIEdgeInsetsMake(10., 8., 12., 15.)
#define kTLPhoneFormViewControllerContainerYOrigin 36.
#define kTLPhoneFormViewControllerCountryAndAreaPadding 16. 
#define kTLPhoneFormViewControllerLabelAndFieldsPadding 10.
#define kTLPhoneFormViewControllerLabelAndCountryCodePadding 19.
#define kTLPhoneFormViewControllerAreaAndPhonePadding 4.
#define kTLPhoneFormViewControllerPhoneLength 7
#define kTLPhoneFormViewControllerAreaCodeLength 3
#define kTLPhoneFormViewControllerFontSize 12.
#define kTLPhoneFormViewControllerPhoneLabelFontSize 14.5
#define kTLPhoneFormViewControllerCountryLabelFontSize 14.5
#define kTLPhoneFormViewControllerLabelFontColor [UIColor whiteColor]
#define kTLPhoneFormViewControllerPhoneFormat @"###-####"
#define kTLPhoneFormViewControllerPhoneLabel @"Please enter your mobile number"
#define kTLPhoneFormViewControllerCountryCodeLabel @"+1"
#define kTLPhoneFormViewControllerAreaCodePlaceholder @"area code"
#define kTLPhoneFormViewControllerPhonePlaceholder @"phone number"
#define kTLPhoneFormViewControllerInvalidAlertTitle @""
#define kTLPhoneFormViewControllerInvalidAlertMessage @"Seems you entered a " \
    @"wrong number"
#define kTLPhoneFormViewControllerConnectionErrorMessage \
    @"Service unavailable, check your internet connection and try again in " \
    @"a few minutes"
#define kTLPhoneControllerPhoneCode @"+1"
#define kTLPhoneControllerRequesFailureKey @"errorMsg"

// TLConfirmCodeViewController constants
#define kTLConfirmCodeViewControllerContainerYOrigin 46.
#define kTLConfirmCodeViewControllerCodeSize CGSizeMake(268., 32.)
#define kTLConfirmCodeViewControllerCodeLength 6
#define kTLConfirmCodeViewControllerCodePlaceholder \
    @"Enter your access code"
#define kTLConfirmCodeViewControllerCodeContentInset \
    UIEdgeInsetsMake(10., 7., 12., 7.)
#define kTLTChatTextContentInset \
UIEdgeInsetsMake(5, 7., 3., 7.)

// TLAccountDataViewController constants
#define kTLProfileAccountLabelText @"CLICK BELOW TO TAKE YOUR PROFILE PICTURE"
#define kTLProfileAccountLabelFontName @"BebasNeue"
#define kTLProfileAccountLabelFontSize 20
#define kTLProfileAccountLabelColor [UIColor whiteColor]
#define kTLAccountDataFormViewControllerTextContentInset \
    UIEdgeInsetsMake(10., 7., 12., 7.)
#define kTLProfilePhoneLabelFontSize 15.
#define kTLHorizontalProfilePhoneLabelSize 320.
#define kTLTextFieldHorizontalMargins 26.
#define kTLPhotoButtomSideSize 94.
#define kTLVerticalToDataLabelMagin 32.
#define kTLVerticalToDataLabelSize 22.
#define kTLVerticalToPhotoButtonMagin 21.
#define kTLVerticalToFirstNameFieldMagin 23.
#define kTLVerticalToFirstNameFieldSize 32.
#define kTLVerticalToLastNameFieldMagin 23.
#define kTLVerticalToLastNameFieldSize 32.
#define kTLAccountDataFormViewControllerFirstNamePlaceholder @"First name"
#define kTLAccountDataFormViewControllerLastNamePlaceholder @"Last Name"
#define kTLAccountDataFormTextFieldMaxSize 15

// TLTChatViewController constants
#define kTLTChatViewControllerUserNickname @"Me"
#define kTLTChatViewControllerTMojiIcon @"tmoji"
#define kTLTChatViewControllerKeyboardIcon @"keyboard"
#define kTLTChatViewControllerSendIcon @"send"

// TLTMojiInputView view constants
// Individual elements
#define kTLTMojiSymbol @"`"
#define kTLTMojiInputViewVPageSize CGSizeMake(320., 161.)
#define kTLTMojiInputViewTMojiSize CGSizeMake(80., 80.)
#define kTLTMojiInputViewPageControlSize CGSizeMake(320., 20.)
#define kTLTMojiInputViewCategoryButtonSize CGSizeMake(79., 35.)
// Each component
// page + page control
#define kTLTMojiInputViewScrollerSize CGSizeMake(320., 181.)
// category button's height
#define kTLTMojiInputViewCategoryBarSize CGSizeMake(320., 35.)
// page + page control + category bar
#define kTLTMojiInpuViewSize CGSizeMake(320., 216.)

// XMPP backend conf
#define kTLHostDomain @"23.21.209.91"
#define kTLHostPort 5222

// User defaults preferences
#define kTLUsernamePreference @"username_preference"
#define kTLPasswordPreference @"password_preference"

// Backend conf
#ifdef DEBUG
    #define TL_BACKEND_HOST_NAME @"0.0.0.0:9090"
#else
    #define TL_BACKEND_HOST_NAME @"www.whatsappclone.com"
#endif
#define TL_DEFAULT_PARAMETER_METHOD @"POST"
#define TL_PUT_PARAMETER_METHOD @"PUT"
#define TL_BACKEND_BASE_URL @"http://" TL_BACKEND_HOST_NAME @"/plugins/"
// Endpoint-construction helper
#define ENDPOINT(url) TL_BACKEND_BASE_URL url
#define ENDPOINT_FROM_STRING(url) \
    [TL_BACKEND_BASE_URL stringByAppendingString:url]
// Helper for forming URL calls
#define URL(...) [NSURL URLWithString:[NSString stringWithFormat:__VA_ARGS__]]
#define URL_WITHOUT_PARAMETERS(...) [NSURL URLWithString:__VA_ARGS__]

// Backend endpoints
#define TL_BACKEND_POST_PHONE_NUMBER @"verificationCode?phone=%@"
#define TL_BACKEND_POST_VERIFICATION_CODE @"verificationCode?phone=%@&" \
    @"verificationCode=%@"

//amazon aws
#define TL_AMAZON_AWS_ACCESS_KEY @"whats"
#define TL_AMAZON_AWS_SECRET_KEY @"up"
#define TL_AMAZON_S3_CURRENT_BUCKET @"whatsappclone.something"
