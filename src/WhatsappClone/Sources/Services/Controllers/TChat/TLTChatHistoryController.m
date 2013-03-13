#import "Application/TLConstants.h"

#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "TLMessageLogManager.h"
#import "TLTChatHistoryController.h"

@interface TLTChatHistoryController()

@property (nonatomic, weak) id<TLTChatHistoryControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *buddies;
@end

@implementation TLTChatHistoryController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLNewMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLDidBuddyVCardUpdatedNotification object:nil];
}
#pragma mark -
#pragma mark TLBaseController

@synthesize delegate;
@synthesize buddies;

#pragma mark -
#pragma mark TLTChatHistoryController
@synthesize storage;

- (id<TLMessageLogStorage>)storage
{
    if (storage == nil) {
        storage = [[TLMessageLogManager sharedInstance] storage];
    }
    return storage;
}

- (id)initWithDelegate:(id<TLTChatHistoryControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(receivedNewMessageNotification:)
            name:kTLNewMessageNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(receivedNewMessageNotification:)
            name:kTLDidBuddyVCardUpdatedNotification
            object:nil];
    }
    return self;
}
- (void)populateBuddies
{
    //setting the chat history
    NSArray  *dateSort = [NSArray arrayWithObject:[NSSortDescriptor
        sortDescriptorWithKey:@"date" ascending:NO]];

    self.buddies = [NSMutableArray arrayWithArray:
        [self.storage buddiesByMessagesWithSortDescriptors:dateSort]];
}

- (NSInteger)buddiesCount
{
    return [self.buddies count];
}

- (NSDictionary *)buddyAtIndex:(NSInteger)index
{
    TLBuddy *buddy = [self.buddies objectAtIndex:index];

    //get the real updated buddy info from roster
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    TLBuddy *rosterBuddy = [[manager buddyList]
        buddyForAccountName:buddy.accountName];

    if (rosterBuddy.displayName != nil) {
        buddy.displayName = rosterBuddy.displayName;
    }
    if (rosterBuddy.photo != nil) {
        buddy.photo = rosterBuddy.photo;
    }

    NSString *stringMessage = buddy.lastMessage.message;
    if ([buddy.lastMessage isATmojiMessage]) {
        if (buddy.lastMessage.received) {
            stringMessage = [NSString stringWithFormat:@"%@ sent you a Tmoji.",
                buddy.displayName];
        } else {
            stringMessage = @"You sent a Tmoji.";
        }
    }

    if ([buddy.lastMessage isAMediaMessage]) {
        if (buddy.lastMessage.received) {
            stringMessage = [NSString stringWithFormat:@"%@ sent you a %@.",
                buddy.displayName, [buddy.lastMessage mediaDescription]];
        } else {
            stringMessage = [NSString stringWithFormat:@"You sent a %@.",
                          [buddy.lastMessage mediaDescription]];
        }
    }

    NSMutableDictionary *sendDict =
        [NSMutableDictionary dictionaryWithDictionary:@{
        @"accountName": buddy.accountName,
        @"displayName": buddy.displayName,
        @"lastMessage": stringMessage,
        @"lastDate": buddy.lastMessage.date,
        @"unreadMessages":
            [NSNumber numberWithInteger:[buddy unreadMessages]]
    }];

    if (buddy.photo != nil) {
        [sendDict setObject:buddy.photo forKey:@"photo"];
    }
    return sendDict;
}

#pragma mark -
#pragma mark Notifications

- (void)receivedNewMessageNotification:(NSNotification *)notification
{
    [self.storage reloadStorage];
    [self populateBuddies];
    [self.delegate updateData];
}
@end
