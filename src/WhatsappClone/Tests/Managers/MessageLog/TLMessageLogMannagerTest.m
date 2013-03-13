#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Services/Models/TLBuddy.h"

#import "Managers/MessageLog/TLMessageLogManager.h"

@interface TLMessageLogMannagerTest: SenTestCase
- (NSArray *)getMessagesData;
@end

@implementation TLMessageLogMannagerTest

- (NSArray *)getMessagesData
{
    NSDictionary *message1Data = @{
        @"message":@"aMessage",
        @"jid":@"aJid",
        @"displayName":@"aName",
        @"received":@YES,
        @"unread":@YES,
        @"date":[NSDate date],
    };
    NSDictionary *message2Data = @{
        @"message":@"aMessage",
        @"jid":@"aJid",
        @"displayName":@"aName",
        @"received":@NO,
        @"unread":@YES,
        @"date":[NSDate date],
    };
    NSDictionary *message3Data = @{
        @"message":@"aMessage",
        @"jid":@"aJid",
        @"displayName":@"aName",
        @"received":@YES,
        @"unread":@NO,
        @"date":[NSDate date],
    };
    return @[message1Data, message2Data, message3Data];
}

#pragma mark -
#pragma mark TLMessageLogManagerTest

- (void)setUp
{
    STAssertNoThrow([[[TLMessageLogManager sharedInstance] storage]
        setFixture:[self getMessagesData]], @"Cannot charge the fixtures");
}

#pragma mark -
#pragma mark TLMessageLogManager

- (void)testsharedInstanceShouldReturnATLMessageLogManager
{
    // setup

    TLMessageLogManager *logMannager = [TLMessageLogManager sharedInstance];

    // action
    
    // assert
    assertThat(logMannager,
            instanceOf([TLMessageLogManager class]));
}

- (void)testStorageShouldReturnATLMessageLogStorageProtocol
{
    // setup
    id logStorage = [[TLMessageLogManager sharedInstance] storage];

    // action
    
    // assert
    assertThat(logStorage,
            conformsTo(@protocol(TLMessageLogStorage)));
}

- (void)testReloadStorageSouldRecoverAStorageMessagesInMessageLog
{
    //setUp
    id<TLMessageLogStorage>logStorage = 
        [[TLMessageLogManager sharedInstance] storage];

    //action
    [logStorage reloadStorage];

    //assert
    assertThat(logStorage.messages, instanceOf([NSArray class]));
    assertThat(logStorage.messages,
        hasCountOf([[self getMessagesData] count]));
}

- (void)testReloadStorageSouldCleanPreviousStorageMessages
{
    //setUp
    id<TLMessageLogStorage>logStorage = 
        [[TLMessageLogManager sharedInstance] storage];

    //action
    [logStorage reloadStorage];
    [logStorage reloadStorage];     //the seccond time is intentional

    //assert
    assertThat(logStorage.messages,
        hasCountOf([[self getMessagesData] count]));
}

//countUnreadMessagesForBuddy: method
- (void)testCountUnreadMessagesForBuddyShouldCountUnreadMessages
{
    // setup
    id<TLMessageLogStorage>logStorage = 
        [[TLMessageLogManager sharedInstance] storage];

    TLBuddy *testBuddy = [TLBuddy buddyWithDisplayName:@"aName"
        accountName:@"aJid"];

    // action
    NSInteger countOffline =
        [logStorage countUnreadMessagesForBuddy:testBuddy];

    // assert
    assertThat([NSNumber numberWithInteger:countOffline],
        equalToInt(2));
}

//setUnreadMessagesAsReadForBuddyAccountName: method
- (void)testSetUnreadMessagesAsReadForBuddyAccountNameShouldSetAllMessagesAsRead
{
    // setup
    id<TLMessageLogStorage>logStorage = 
        [[TLMessageLogManager sharedInstance] storage];

    TLBuddy *testBuddy = [TLBuddy buddyWithDisplayName:@"aName"
        accountName:@"aJid"];

    // action
    [logStorage setUnreadMessagesAsReadForBuddyAcountName:@"aJid"];
    NSInteger countOffline =
        [logStorage countUnreadMessagesForBuddy:testBuddy];

    // assert
    assertThat([NSNumber numberWithInteger:countOffline],
        equalToInt(0));
}
@end

