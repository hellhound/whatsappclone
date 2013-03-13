#import "Application/TLConstants.h"
#import "Services/Models/TLAccount.h"
#import "TLConfirmController.h"

@interface TLConfirmController ()

@property (nonatomic, weak) id<TLConfirmControllerDelegate> delegate;
@property (nonatomic, strong) id<TLAPIRegistrationClient> registrationEndpoint;

@end

@implementation TLConfirmController

#pragma mark -
#pragma mark TLBaseController

@synthesize delegate;
@synthesize registrationEndpoint;

- (id<TLAPIRegistrationClient>)registrationEndpoint
{
    if (registrationEndpoint == nil) {
        registrationEndpoint = (id<TLAPIRegistrationClient>)[[TLAPIManager
        sharedInstanceWithClientProtocol:
        @protocol(TLAPIRegistrationClient)] client];
    }
    return registrationEndpoint;
}

#pragma mark -
#pragma mark TLConfirmController

- (id)initWithEndpoint:(id<TLAPIRegistrationClient>)endpoint
{
    if ((self = [super init]) != nil) {
        self.registrationEndpoint = endpoint;
    }
    return self;
}

- (BOOL)isConfirmationCodeValid:(NSString *)string
{
    NSUInteger maximumLength = kTLConfirmCodeViewControllerCodeLength;
    return  [string length] == maximumLength;
}

- (void)sendVerificationCode:(NSString *)code
{
    TLAccount *account = [TLAccount sharedInstance];

    __block TLConfirmController *controller = self;
    self.registrationEndpoint.success = ^(NSURLRequest *request,
            NSHTTPURLResponse *response, id userInfo){
        [controller.delegate didSuccessVerificationSaved];
        account.password = code;
    };

    self.registrationEndpoint.failure = ^(NSURLRequest *request,
            NSHTTPURLResponse *response, NSError *error, id userInfo){

        NSString *errorMessage = userInfo[kTLPhoneControllerRequesFailureKey];
        if (errorMessage == nil) {
            errorMessage = kTLPhoneFormViewControllerConnectionErrorMessage;
        }
        [controller.delegate
            didFailedVerificationSavedWithErrorMessage:errorMessage];
    };

    [self.registrationEndpoint postVerificationCode:code
        forPhoneNumber:account.phone];

}
@end
