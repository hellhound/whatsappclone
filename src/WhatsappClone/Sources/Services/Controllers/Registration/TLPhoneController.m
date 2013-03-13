#import <Foundation/Foundation.h>

#import "Application/TLConstants.h"
#import "Services/Models/TLAccount.h"
#import "TLPhoneController.h"

@interface TLPhoneController()
    @property (nonatomic, weak) id<TLTPhoneControllerDelegate> delegate;
@end

@implementation TLPhoneController

@synthesize delegate;

- (BOOL)verifyPhoneStringAndSend:(NSString *)phoneStr
{
    BOOL isAPhoneValid = [TLAccount verifyPhoneNumber:phoneStr];

    if (isAPhoneValid) {
        TLAccount *account = [TLAccount sharedInstance];

        // set the valid phone number into the TLAccount singleton
        account.phone = phoneStr;
        [self sendPhoneNumber:phoneStr];
    }
    return isAPhoneValid;
}

- (void)sendPhoneNumber:(NSString *)phoneStr
{
    id<TLAPIRegistrationClient> registrationEndpoint =
        (id<TLAPIRegistrationClient>)[[TLAPIManager
        sharedInstanceWithClientProtocol:
        @protocol(TLAPIRegistrationClient)] client];

    registrationEndpoint.success = ^(NSURLRequest *request,
            NSHTTPURLResponse *response, id userInfo){
        [self.delegate phoneDidSendSuccessPhone];
    };
    registrationEndpoint.failure = ^(NSURLRequest *request,
            NSHTTPURLResponse *response, NSError *error, id userInfo){
        NSString *errorMessage = userInfo[kTLPhoneControllerRequesFailureKey];
        if (errorMessage == nil) {
            errorMessage = kTLPhoneFormViewControllerConnectionErrorMessage;
        }
        [self.delegate phoneDidSendFailedPhoneWithMessage: errorMessage];
    };

    TLAccount *account = [TLAccount sharedInstance];
    account.phone = [kTLPhoneControllerPhoneCode
        stringByAppendingString:phoneStr];

    [registrationEndpoint postPhoneNumber:account.phone];
}
@end
