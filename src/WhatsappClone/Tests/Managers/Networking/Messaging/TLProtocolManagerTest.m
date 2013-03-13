#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Managers/Networking/Messaging/TLProtocolManager.h"

static NSString *const kAString = @"aString";

@interface TLProtocolManagerTest: SenTestCase

- (void)gotNotification:(NSNotification *)notification;
@end

@implementation TLProtocolManagerTest

- (void)gotNotification:(NSNotification *)notification
{
}

#pragma mark -
#pragma mark TLProtocolManagerTest

- (void)setUp
{
    [TLProtocolManager replaceInstance:nil];
}

- (void)testProtocolShouldExistAndReturnsAManager
{
    // setup-up
    TLProtocolManager *manager = [[TLProtocolManager alloc] init];
    
    // action
    id<TLProtocol> protocol = manager.protocol;    
    
    // assert
    assertThat(protocol, notNilValue());
}

- (void)testProtocolShouldReturnConformingManagerToTLProtocol
{
    // setup-up
    TLProtocolManager *manager = [[TLProtocolManager alloc] init];

    // action
    id<TLProtocol> protocolManager = manager.protocol;

    // assert
    assertThat(protocolManager, conformsTo(@protocol(TLProtocol)));
}

- (void)testSharedInstanceShouldReturnATLProtocolManagerSingleton
{
    // set-up
    TLProtocolManager *manager = nil;

    // action
    manager = [TLProtocolManager sharedInstance];

    // assert
    assertThat(manager, instanceOf([TLProtocolManager class]));
    assertThat(manager, equalTo([[TLProtocolManager alloc] init]));
    assertThat(manager, equalTo([manager copy]));
}

- (void)testProtocolAccountShouldGetATLAccount
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    TLAccount *account = [[TLAccount alloc] init];

    manager.account = account;

    // action
    id result = manager.account;

    // assert
    assertThat(result, equalTo(account));
}

- (void)testProtocolAccountShouldSetATLAccount
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    TLAccount *account = [[TLAccount alloc] init];

    // action
    manager.account = account;

    // assert
    assertThat(manager.account, equalTo(account));
}

- (void)testProtocolBuddyListShouldGetATLBuddyList
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    TLBuddyList *buddyList = [[TLBuddyList alloc] init];

    manager.buddyList = buddyList;

    // action
    id result = manager.buddyList;

    // assert
    assertThat(result, equalTo(buddyList));
}

- (void)testProtocolBuddyShouldSetATLBuddyList
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    TLBuddyList *buddyList = [[TLBuddyList alloc] init];

    // action
    manager.buddyList = buddyList;

    // assert
    assertThat(manager.buddyList, equalTo(buddyList));
}

- (void)testSendMessageShouldNotSendMesssageWithLengthZero
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    id<TLProtocolBridge> mockBridge =
        mockProtocol(@protocol(TLProtocolBridge));
    TLMessage *mockMessage = mock([TLMessage class]);

    [given([mockMessage message]) willReturn:@""];
    manager.bridge = mockBridge;

    // action
    [manager sendMessage:mockMessage];
    
    // verification
    [verifyCount(mockBridge, never()) sendMessageBridge:anything()];
}

- (void)testSendMessageShouldSendATLMessage
{
    // set-up
    id<TLProtocol> manager = [[[TLProtocolManager alloc] init] protocol];
    id<TLMessageLogStorage> mockStorage =
        mockProtocol(@protocol(TLMessageLogStorage));
    id<TLProtocolBridge> mockBridge =
        mockProtocol(@protocol(TLProtocolBridge));
    TLMessage *mockMessage = mock([TLMessage class]);

    [given([mockMessage message]) willReturn:kAString];
    manager.storage = mockStorage;
    manager.bridge = mockBridge;

    // action
    [manager sendMessage:mockMessage];
    
    // verification
    [verifyCount(mockBridge, times(1)) sendMessageBridge:anything()];
    [verifyCount(mockStorage, times(1)) addMessage:anything()];
}

- (void)testConnectWithPasswordShouldCallConnectBridge
{
    // set-up
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    id<TLProtocolBridge> mockBridge = mockProtocol(@protocol(TLProtocolBridge));
    TLAccount *mockAccount = mock([TLAccount class]);

    [given([mockAccount getUUID]) willReturn:kAString];
    manager.account = mockAccount;
    manager.bridge = mockBridge;

    // action
    [manager connectWithPassword:kAString];

    // verification
    [verifyCount(mockBridge, times(1)) connectBridge:0];
}

- (void)testConnectWithPasswordShouldNotCallConnectBridgeWithoutUsername
{
    // set-up
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    id<TLProtocolBridge> mockBridge = mockProtocol(@protocol(TLProtocolBridge));

    manager.bridge = mockBridge;

    // action
    [manager connectWithPassword:kAString];

    // verification
    [verifyCount(mockBridge, never()) connectBridge:0];
}

- (void)testConnectWithPasswordShouldNotCallConnectBridgeWithoutPassword
{
    // set-up
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    id<TLProtocolBridge> mockBridge = mockProtocol(@protocol(TLProtocolBridge));
    TLAccount *mockAccount = mock([TLAccount class]);

    [given([mockAccount getUUID]) willReturn:kAString];
    manager.account = mockAccount;
    manager.bridge = mockBridge;

    // action
    [manager connectWithPassword:nil];

    // verification
    [verifyCount(mockBridge, never()) connectBridge:0];
}

- (void)testConnectWithPasswordShouldPostNotificationWhenConnectBridgeFail
{
    // set-up
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    id<TLProtocolBridge> mockBridge = mockProtocol(@protocol(TLProtocolBridge));
    TLAccount *mockAccount = mock([TLAccount class]);
    id mockObserver = mock([self class]);

    [given([mockAccount getUUID]) willReturn:kAString];
    [[given([mockBridge connectBridge:0]) withMatcher:anything()]
        willReturn:[NSNumber numberWithBool:NO]];
    manager.account = mockAccount;
    manager.bridge = mockBridge;
    [[NSNotificationCenter defaultCenter] addObserver:mockObserver
        selector:@selector(gotNotification:)
        name:kTLProtocolLoginFailNotification object:manager];

    // action
    [manager connectWithPassword:kAString];

    // verification
    [verifyCount(mockObserver, times(1))
        gotNotification:(NSNotification *)anything()];

    // tear down
    [[NSNotificationCenter defaultCenter] removeObserver:mockObserver
        name:kTLProtocolLoginFailNotification object:manager];
}
@end
