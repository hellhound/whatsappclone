#import "Application/TLConstants.h"
#import "Categories/NSString+TLURLEncoding.h"
#import "TLRegistrationClient.h"

@implementation TLRegistrationClient

#pragma mark -
#pragma mark <TLAPIRegistrationClient>

- (void)postPhoneNumber:(NSString *)phoneNumber
{
    [self postToURL:URL(ENDPOINT(TL_BACKEND_POST_PHONE_NUMBER),
            [phoneNumber URLEncodedString])
        parameters:nil];
}

- (void)postVerificationCode:(NSString *)verificationCode
             forPhoneNumber:(NSString *)phoneNumber
{
    [self postToURL:URL(ENDPOINT(TL_BACKEND_POST_VERIFICATION_CODE),
            [phoneNumber URLEncodedString], [verificationCode URLEncodedString])
        parameters:nil withMethod:TL_PUT_PARAMETER_METHOD];
}
@end
