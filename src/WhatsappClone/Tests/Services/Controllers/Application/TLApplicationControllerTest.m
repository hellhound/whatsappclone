#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Services/Controllers/Application/TLApplicationController.h"

static NSString *const kAPhone = @"3019999999";
static NSString *const kAPassword = @"3999";

@interface TLApplicationControllerTest: SenTestCase

- (TLAccount *)getAccount;
@end

@implementation TLApplicationControllerTest

- (TLAccount *)getAccount
{
    TLAccount *account = [TLAccount sharedInstance];

    account.phone = kAPhone;
    return account;
}

- (void)setUp
{
    [TLAccountManager replaceInstance:nil];
    [TLAccountManager setStorage:nil];
    [TLAccount replaceInstance:nil];
    // TODO remove after demo!
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)testConnectShouldCallConnectWithPassword
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    id<TLProtocol> mockManager = mockProtocol(@protocol(TLProtocol));

    controller.manager = mockManager;

    // action
    [controller connect];
    
    // verify
    [verifyCount(mockManager, times(1)) connectWithPassword:nil];
}

- (void)testConnectShouldUseSharedInstance
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    id<TLProtocol> mockManager = mockProtocol(@protocol(TLProtocol));
    Class mockAccountClass = mockClass([TLAccount class]);

    controller.manager = mockManager;
    controller.accountClass = mockAccountClass;

    // action
    [controller connect];
    
    // verify
    [verifyCount(mockAccountClass, times(1)) sharedInstance];
}

- (void)testDisconnectShouldCallManagerDisconnect
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    id<TLProtocol> mockManager = mockProtocol(@protocol(TLProtocol));

    controller.manager = mockManager;

    // action
    [controller disconnect];
    
    // verify
    [verifyCount(mockManager, times(1)) disconnect];
}

- (void)testInitShouldCallAccountStorageGetAccount
{
    // setup
    id<TLAccountStorage> mockStorage =
        mockProtocol(@protocol(TLAccountStorage));

    [TLApplicationController replaceAccountStorage:mockStorage];

#pragma clang diagnostic push
    // supress warnings of unused value
#pragma clang diagnostic ignored "-Wunused-value"
    // action
    [[TLApplicationController alloc] init];
#pragma clang diagnostic pop

    // verify
    [verifyCount(mockStorage, times(1)) getAccount];
}

- (void)testShouldPresentRegistrationFormShouldReturnNo
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    Class mockAccountClass = mockClass([TLAccount class]);
    TLAccount *account = [self getAccount];
    account.phone = kAPhone;
    account.password = kAPassword;

    controller.accountClass = mockAccountClass;
    [given([mockAccountClass sharedInstance]) willReturn:account];

    // action
    NSNumber *returned =
        [NSNumber numberWithBool:[controller shouldPresentRegistrationForm]];

    // assert
    assertThat(returned, equalToBool(NO));
}

- (void)testShouldPresentRegistrationFormShouldReturnYesWhenOnlyAAccount
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    Class mockAccountClass = mockClass([TLAccount class]);

    controller.accountClass = mockAccountClass;
    [given([mockAccountClass sharedInstance]) willReturn:nil];

    // action
    NSNumber *returned =
        [NSNumber numberWithBool:[controller shouldPresentRegistrationForm]];

    // assert
    assertThat(returned, equalToBool(YES));
}

- (void)testShouldPresentRegistrationFormShouldReturnYesWhenAccountHasNoPassword
{
    // setup
    TLApplicationController *controller =
        [[TLApplicationController alloc] init];
    Class mockAccountClass = mockClass([TLAccount class]);
    TLAccount *account = [self getAccount];
    account.phone = kAPhone;

    controller.accountClass = mockAccountClass;
    [given([mockAccountClass sharedInstance]) willReturn:account];

    // action
    NSNumber *returned =
        [NSNumber numberWithBool:[controller shouldPresentRegistrationForm]];

    // assert
    assertThat(returned, equalToBool(YES));
}
@end
