#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Services/Models/TLAccount.h"
#import "Services/Controllers/Registration/TLAccountDataController.h"

@interface TLAccountDataControllerTest: SenTestCase
@end

@implementation TLAccountDataControllerTest

static NSString *const kTestString = @"aString";
static BOOL const kTestBool = YES;
static NSString *const kAPhone = @"3107654321"; // California-area code

//accountWithProtocol: method
- (void)testAccountDataWithProtocolShouldReturnATLAccountDataController
{
    //setup
    id<TLProtocol>mockProtocol = mockProtocol(@protocol(TLProtocol));
    //account
    id controller = [TLAccountDataController
        accountDataControllerWithProtocol:mockProtocol];
    //verify
    assertThat(controller, instanceOf([TLAccountDataController class]));
}

//updateAccountWithFirstName:lastName:photo: method (TLAccount)
- (void)testUpdateAccountWithFirstNameLastNamePhotoShouldUpdateTLAccountInstance
{
    //setup
    TLAccountDataController *controller =
        [[TLAccountDataController alloc] init];
    NSString *firstName = kTestString;
    NSString *lastName = kTestString;
    NSData *photo = [[NSData alloc] init];
    TLAccount *account = [TLAccount sharedInstance];

    //action
    [controller updateAccountWithFirstName:firstName lastName:lastName
        photo:photo];

    //assert
    assertThat(account.firstName, equalTo(firstName));
    assertThat(account.lastName, equalTo(lastName));
    assertThat(account.photo, equalTo(photo));
}

//updateAccountDataWithTLAccount: method (TLProtocolManager)
- (void)testUpdateAccountWithFirstNameLastNamePhotoShouldCallConnectWithPAssword
{
    //setup
    id<TLProtocol>mockProtocol = mockProtocol(@protocol(TLProtocol));
    TLAccountDataController *controller = [TLAccountDataController
        accountDataControllerWithProtocol:mockProtocol];
    TLAccount *account = [TLAccount sharedInstance];

    account.password = kTestString;
    NSString *firstName = kTestString;
    NSString *lastName = kTestString;
    NSData *photo = [[NSData alloc] init];

    //action
    [controller updateAccountWithFirstName:firstName lastName:lastName
        photo:photo];

    //assert
    [verifyCount(mockProtocol, times(1)) connectWithPassword:kTestString];
}

//sendUpdateData method
- (void)testSendUpdateDataShouldcallUpdateAccountDataWithTLAccount
{
    //setup
    id<TLProtocol>mockProtocol = mockProtocol(@protocol(TLProtocol));
#pragma clang diagnostic push
    // supress warnings of unused value
#pragma clang diagnostic ignored "-Wunused-value"
    // action
    [TLAccountDataController accountDataControllerWithProtocol:mockProtocol];
#pragma clang diagnostic pop

    //action
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLProtocolLoginSuccessNotification object:nil];

    //verify
    [verifyCount(mockProtocol, times(1)) updateAccountDataWithTLAccount];
}
@end
