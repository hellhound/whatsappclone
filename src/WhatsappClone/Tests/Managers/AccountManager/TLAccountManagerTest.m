#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Managers/AccountManager/TLAccountManager.h"

static NSString *const kAPhone = @"3019999999"; // California-area code

@interface TLAccountManagerTest: SenTestCase
@end

@implementation TLAccountManagerTest

- (TLAccountManager *)getAccountManager
{
    return [[TLAccountManager alloc] init];
}

- (TLAccount *)getAccount
{
    TLAccount *account = [TLAccount sharedInstance];

    account.phone = kAPhone;
    return account;
}

- (void)setUp
{
    TLAccountManager *manager = [TLAccountManager sharedInstance];

    [manager.storage clearStorage];

    [TLAccountManager replaceInstance:nil];
    [TLAccountManager setStorage:nil];
}

- (void)testSharedInstanceShouldReturnATLAccountManager
{
    // setup
    TLAccountManager *accountManager = nil;

    // action
    accountManager = [TLAccountManager sharedInstance];

    // assert
    assertThat(accountManager, instanceOf([TLAccountManager class]));
}

- (void)testSharedInstanceShouldReturnATLAccountManagerSingleton
{
    // setup
    TLAccountManager *accountManager = [self getAccountManager];
    TLAccountManager *returned = nil;

    // action
    returned = [TLAccountManager sharedInstance];

    // assert
    assertThat(returned, equalTo(accountManager));
}

- (void)testSharedInstanceShouldReturnSameAsCopy
{
    // setup
    TLAccountManager *accountManager = nil;

    // action
    accountManager = [TLAccountManager sharedInstance];

    // assert
    assertThat(accountManager, equalTo([accountManager copy]));
}

- (void)testStorageConformsToTLAccountStorage
{
    // setup
    TLAccountManager *manager = [self getAccountManager];

    // action
    id<TLAccountStorage> storage = manager.storage;

    // assert
    assertThat(storage, conformsTo(@protocol(TLAccountStorage)));
}

- (void)testStorageGetAccountShouldReturnTLAccount
{
    // setup
    TLAccount *account = [self getAccount];
    TLAccountManager *manager = [self getAccountManager];
    id<TLAccountStorage> storage = manager.storage;

    [storage saveAccount:account];

    // action
    TLAccount *returned = [storage getAccount];
    
    // assert
    assertThat(returned, equalTo(account));
}

- (void)testStorageGetAccountShouldReturnNil
{
    // setup
    TLAccountManager *manager = [self getAccountManager];
    id<TLAccountStorage> storage = manager.storage;

    // action
    TLAccount *returned = [storage getAccount];
    
    // assert
    assertThat(returned, nilValue());
}

- (void)testStorageSaveAccountShouldSaveATLAccount
{
    // setup
    TLAccount *account = [self getAccount];
    TLAccountManager *manager = [self getAccountManager];
    id<TLAccountStorage> storage = manager.storage;

    // action
    [storage saveAccount:account];
    
    // assert
    assertThat([storage getAccount], equalTo(account));
}

- (void)testStorageSaveAccountShouldReplacePreviousTLAccount
{
    // setup
    TLAccountManager *manager = [self getAccountManager];
    id<TLAccountStorage> storage = manager.storage;
    TLAccount *account = [self getAccount];
    NSString *previousAccountPhone = kAPhone;
    NSString *replacingAccountPhone = @"3019999991";

    account.phone = previousAccountPhone;
    [storage saveAccount:account];
    account.phone = replacingAccountPhone;

    // action
    [storage saveAccount:account];
    
    // assert
    assertThat([storage getAccount].phone,
        isNot(equalTo(previousAccountPhone)));
}

- (void)testInitShouldCallStorageGetAccount
{
    // setup
    id<TLAccountStorage> mockStorage =
        mockProtocol(@protocol(TLAccountStorage));
    [TLAccountManager setStorage:mockStorage];

#pragma clang diagnostic push
    // supress warnings of unused value
#pragma clang diagnostic ignored "-Wunused-value"
    // action
    [[TLAccountManager alloc] init];
#pragma clang diagnostic pop

    // verify
    [verifyCount(mockStorage, times(1)) getAccount];
}
@end
