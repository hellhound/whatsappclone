#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"

#import "TLTestConstants.h"
#import "Services/Models/TLAccount.h"
#import "Services/Controllers/Registration/TLConfirmController.h"

static NSString *const kAValidConfirmation = @"435678";
static NSString *const kAphone = @"+12422345665";
static NSString *const kAInvalidConfirmation = @"4323458";

@interface TLConfirmControllerTest: SenTestCase
@end

@implementation TLConfirmControllerTest

- (void)testIsConfirmationCodeValidSouldReturnYESForValidString
{
    //setup
    TLConfirmController *controller = [[TLConfirmController alloc] init];

    //action
    BOOL isValid = [controller isConfirmationCodeValid:kAValidConfirmation];

    //verify
    assertThat([NSNumber numberWithBool:isValid], equalTo(NUMBER_YES));
}

- (void)testIsConfirmationCodeValidSouldReturnNOForInvalidString
{
    //setup
    TLConfirmController *controller = [[TLConfirmController alloc] init];

    //action
    BOOL isValid = [controller isConfirmationCodeValid:kAInvalidConfirmation];

    //verify
    assertThat([NSNumber numberWithBool:isValid], equalTo(NUMBER_NO));
}

//method sendVerificationCode:forPhoneNumber:
- (void)testsendVerificationCodeForPhoneNumberShouldCallpostVerificationCode
{
    //setup
    id<TLAPIRegistrationClient> endpointClient =
        mockProtocol(@protocol(TLAPIRegistrationClient));
    TLAccount *account = [TLAccount sharedInstance];
    account.phone = kAphone;

    TLConfirmController *controller = [[TLConfirmController alloc]
        initWithEndpoint:endpointClient];

    //action
    [controller sendVerificationCode:kAValidConfirmation];

    //verify
    [verifyCount(endpointClient, times(1))
        postVerificationCode:kAValidConfirmation forPhoneNumber:kAphone];
}

@end
