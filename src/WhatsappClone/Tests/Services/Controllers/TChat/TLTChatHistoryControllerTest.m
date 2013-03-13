#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"

#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Services/Controllers/TChat/TLTChatHistoryController.h"

@interface TLTChatHistoryControllerTest: SenTestCase
@end

@implementation TLTChatHistoryControllerTest

- (void)testReceivedNewMessageNotificationSouldUpdateData
{
    // set-up
    id<TLTChatHistoryControllerDelegate> delegate =
        mockProtocol(@protocol(TLTChatHistoryControllerDelegate));
    TLTChatHistoryController *historyConttroller = 
        [[TLTChatHistoryController alloc] initWithDelegate:delegate];

    // action
    [historyConttroller receivedNewMessageNotification:nil];

    // verify
    [verifyCount(delegate, times(1)) updateData];
}

- (void)testReceivedNewMessageNotificationSouldReloadStorage
{
    // set-up
    id<TLTChatHistoryControllerDelegate> delegate =
        mockProtocol(@protocol(TLTChatHistoryControllerDelegate));

    TLTChatHistoryController *historyConttroller = 
        [[TLTChatHistoryController alloc] initWithDelegate:delegate];

    id<TLMessageLogStorage> storageMock =
        mockProtocol(@protocol(TLMessageLogStorage));
    historyConttroller.storage = storageMock;

    // action
    [historyConttroller receivedNewMessageNotification:nil];

    // verify
    [verifyCount(storageMock, times(1)) reloadStorage];
}

- (void)testReceivedNewMessageNotificationSouldPopulateBuddies
{
    // set-up
    id<TLTChatHistoryControllerDelegate> delegate =
        mockProtocol(@protocol(TLTChatHistoryControllerDelegate));

    TLTChatHistoryController *historyConttroller = 
        [[TLTChatHistoryController alloc] initWithDelegate:delegate];

    NSArray *sanmpleBuddyArray = @[@"buddy1", @"buddy2"];
    id<TLMessageLogStorage> storageMock =
        mockProtocol(@protocol(TLMessageLogStorage));

    [[given([storageMock buddiesByMessagesWithSortDescriptors:0])
        withMatcher:anything()] willReturn:sanmpleBuddyArray];
    historyConttroller.storage = storageMock;

    // action
    [historyConttroller receivedNewMessageNotification:nil];

    // verify
    assertThat([NSNumber numberWithInteger:
            [historyConttroller buddiesCount]],
            equalToInt([sanmpleBuddyArray count]));
}

@end
