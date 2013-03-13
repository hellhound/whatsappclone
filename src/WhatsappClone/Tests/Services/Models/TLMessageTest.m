#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"
#import "TLTestConstants.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Services/Models/TLBuddy.h"
#import "Services/Models/TLMediaData.h"
#import "Services/Models/TLMessage.h"

@interface TLMessageTest: SenTestCase
@end

@implementation TLMessageTest

static NSString *const kTestString = @"aString";
static BOOL const kTestBool = YES;

//dummy objects
- (TLBuddy *)createDummyBuddy
{
    return [[TLBuddy alloc] init];
}

//message property
- (void)testMessageShouldReturnANSString
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    message.message = kTestString;
    
    // assert
    assertThat(message.message, instanceOf([NSString class]));
}

- (void)testMessageShouldSetANSString
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    message.message = kTestString;
    
    // assert
    assertThat(message.message, equalTo(kTestString));
}

//buddy property
- (void)testBuddyShouldReturnATLBuddy
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];
    TLBuddy *buddy = [self createDummyBuddy];

    // action
    message.buddy = buddy;
    
    // assert
    assertThat(buddy, instanceOf([TLBuddy class]));
}

//received property
- (void)testReceivedShouldSetABOOL
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    message.received = kTestBool;
    
    // assert
    assertThat([NSNumber numberWithBool:message.received],
        equalTo([NSNumber numberWithBool:kTestBool]));
}

//unread property
- (void)testUnreadShouldSetABOOL
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    message.unread = kTestBool;
    
    // assert
    assertThat([NSNumber numberWithBool:message.unread],
        equalTo([NSNumber numberWithBool:kTestBool]));
}

//date property
- (void)testDateShouldReturnANSDate
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    message.date = [NSDate date];
    
    // assert
    assertThat(message.date, instanceOf([NSDate class]));
}

//mediaData property
- (void)testMediaDataShouldReturnATLMediaData
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];
    TLMediaData *sampleData = [[TLMediaData alloc] init];

    // action
    message.mediaData = sampleData;
    
    // assert
    assertThat(message.mediaData, equalTo(sampleData));
}

- (void)testMessageShouldSetANSDate
{
    // setup
    TLMessage *message = [[TLMessage alloc] init];

    // action
    NSDate *date = [NSDate date];
    message.date = date;
    
    // assert
    assertThat(message.date, equalTo(date));
}

//messageWithBuddy:message: method
- (void)testMessageWithBuddyMessageShouldReturnTLMessage
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
            message:kTestString];

    // action
    TLBuddy *buddyProperty = message.buddy;
    NSString *messageProperty = message.message;
    NSDate *dateProperty = message.date;
    
    // assert
    assertThat(message, instanceOf([TLMessage class]));
    assertThat(messageProperty, instanceOf([NSString class]));
    assertThat(buddyProperty, equalTo(buddy));
    assertThat(dateProperty, instanceOf([NSDate class]));
}

//messageWithBuddy:message:received: method
- (void)testMessageWithBuddyMessageReceivedShouldReturnTLMessage
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
         message:kTestString received:kTestBool];

    // action
    TLBuddy *buddyProperty = message.buddy;
    NSString *messageProperty = message.message;
    NSDate *dateProperty = message.date;
    
    // assert
    assertThat(message, instanceOf([TLMessage class]));
    assertThat(messageProperty, instanceOf([NSString class]));
    assertThat(buddyProperty, equalTo(buddy));
    assertThat([NSNumber numberWithBool:message.received],
        equalTo([NSNumber numberWithBool:kTestBool]));
    assertThat(dateProperty, instanceOf([NSDate class]));
}

//messageWithBuddy:message:received:unread: method
- (void)testMessageWithBuddyMessageReceivedUnreadShouldReturnTLMessage
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:kTestString received:kTestBool unread:kTestBool];

    // action

    // assert
    assertThat([NSNumber numberWithBool:message.unread],
        equalTo([NSNumber numberWithBool:kTestBool]));
}

//messageWithBuddy:mediaData:received:unread: method
- (void)testMessageWithBuddyMediaDataReceivedUnreadShouldReturnTLMessage
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMediaData *sampleData = [[TLMediaData alloc] init];

    // action
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        mediaData:sampleData received:kTestBool unread:kTestBool];

    // assert
    assertThat(message, instanceOf([TLMessage class]));
    assertThat([NSNumber numberWithBool:message.unread],
        equalTo([NSNumber numberWithBool:kTestBool]));
    assertThat(message.mediaData, equalTo(sampleData));
}

//isATmojiMessage method
- (void)testisATmojiMessageWithTmojiShouldReturnYES
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    NSString *tmojiString = [NSString stringWithFormat:@"%@%@%@", kTLTMojiSymbol,
             kTestString, kTLTMojiSymbol];

    // action
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:tmojiString received:kTestBool unread:kTestBool];

    // assert
    assertThat([NSNumber numberWithBool:[message isATmojiMessage]],
        equalTo([NSNumber numberWithBool:YES]));
}

- (void)testisATmojiMessageWithoutaLetterTmojiShouldReturnNO
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    NSString *tmojiString = [NSString stringWithFormat:@"%@%@", kTLTMojiSymbol,
             kTestString];

    // action
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:tmojiString received:kTestBool unread:kTestBool];

    // assert
    assertThat([NSNumber numberWithBool:[message isATmojiMessage]],
        equalTo([NSNumber numberWithBool:NO]));
}

- (void)testisATmojiMessageWithMessageShouldReturnNO
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:kTLTMojiSymbol received:kTestBool unread:kTestBool];

    // action

    // assert
    assertThat([NSNumber numberWithBool:[message isATmojiMessage]],
        equalTo([NSNumber numberWithBool:NO]));
}

- (void)testisATmojiMessageWithoutMessageShouldReturnNO
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:@"" received:kTestBool unread:kTestBool];

    // action

    // assert
    assertThat([NSNumber numberWithBool:[message isATmojiMessage]],
        equalTo([NSNumber numberWithBool:NO]));
}
- (void)testisATmojiMessageWithOnlySymbolShouldReturnNO
{
    // setup
    TLBuddy *buddy = [self createDummyBuddy];
    TLMessage *message = [TLMessage messageWithBuddy:buddy
        message:kTLTMojiSymbol received:kTestBool unread:kTestBool];

    // action

    // assert
    assertThat([NSNumber numberWithBool:[message isATmojiMessage]],
        equalTo([NSNumber numberWithBool:NO]));
}

- (void)testSendShouldCallSendMessage
{
    //setup
    id<TLProtocol> mockProtocol = mockProtocol(@protocol(TLProtocol));
    TLMessage *message = [[TLMessage alloc] initWithProtocol:mockProtocol];
    //action
    message.message = kTestString;
    [message send];
    //assert
    [verify(mockProtocol) sendMessage:message];
}

- (void)testSendShouldCallSendViaMedia
{
    //setup
    id<TLProtocol> mockProtocol = mockProtocol(@protocol(TLProtocol));
    TLMessage *message = [[TLMessage alloc] initWithProtocol:mockProtocol];
    //action
    message.message = kTestString;
    message.mediaData = [[TLMediaData alloc] init];
    [message send];
    //assert
    [verify(mockProtocol) sendViaMedia:message];
}

@end
