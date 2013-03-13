#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"
#import "TLTestConstants.h"
#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Services/Models/TLMessage.h"
#import "Services/Models/TLBuddy.h"

@interface TLBuddyTest: SenTestCase
@end

@implementation TLBuddyTest

static NSString *const kTestString = @"aString";

//dummy objects
- (TLMessage *)createDummyMessage
{
    return [[TLMessage alloc] init];
}

//displayName property
- (void)testDisplayNameShouldReturnANSString
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];

    // action
    buddy.displayName = kTestString;
    
    // assert
    assertThat([NSNumber numberWithBool:
       [buddy.displayName isKindOfClass:[NSString class]]],
       equalTo(NUMBER_YES));
}

- (void)testDisplayNameShouldSetANSString
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];

    // action
    buddy.displayName = kTestString;
    
    // assert
    assertThat(buddy.displayName, equalTo(kTestString));
}

//accountName property
- (void)testAccountNameShouldReturnANSString
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];

    // action
    buddy.accountName = kTestString;
    
    // assert
    assertThat([NSNumber numberWithBool:
       [buddy.accountName isKindOfClass:[NSString class]]],
       equalTo(NUMBER_YES));
}

- (void)testAccountNameShouldSetANSString
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];

    // action
    buddy.accountName = kTestString;
    
    // assert
    assertThat(buddy.accountName, equalTo(kTestString));
}

//lastMessage property
- (void)testLastMessageShouldReturnTLMessage
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];
    TLMessage *message = [self createDummyMessage];

    // action
    buddy.lastMessage = message;
    
    // assert
    assertThat(message, instanceOf([TLMessage class]));
}

//photo property
- (void)testPhotoNameShouldReturnANSData
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];

    // action
    buddy.photo = [[NSData alloc] init];
    
    // assert
    assertThat(buddy.photo, instanceOf([NSData class]));
}

- (void)testPhotoNameShouldSetANSData
{
    // setup
    TLBuddy *buddy = [[TLBuddy alloc] init];
    NSData *aData = [[NSData alloc] init];

    // action
    buddy.photo = aData;
    
    // assert
    assertThat(buddy.photo, equalTo(aData));
}

//buddyWithDisplayName:accountname: method
- (void)testBuddyWithDisplayNameAccountnameShouldReturnTLBuddy
{
    // setup
    TLBuddy *buddy = [TLBuddy buddyWithDisplayName:kTestString
            accountName:kTestString];

    // action
    NSString *displayName = buddy.displayName;
    NSString *accountName = buddy.accountName;
    
    // assert
    assertThat(buddy, instanceOf([TLBuddy class]));
    assertThat(displayName, equalTo(kTestString));
    assertThat(accountName, equalTo(kTestString));
}

//unreadMessages method
- (void)testUnreadMessagesShoudCallCountUnreadMessagesForBuddy
{
    // setup
    TLBuddy *buddy = [TLBuddy buddyWithDisplayName:kTestString
            accountName:kTestString];
    id<TLMessageLogStorage> storageMock =
        mockProtocol(@protocol(TLMessageLogStorage));
    buddy.storage = storageMock;

    //// action
    [buddy unreadMessages];
    
    //// assert
    [verifyCount(storageMock, times(1)) countUnreadMessagesForBuddy:buddy];
}
@end
