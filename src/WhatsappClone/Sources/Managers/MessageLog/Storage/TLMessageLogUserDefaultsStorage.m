#import "Application/TLConstants.h"
#import "Services/Models/TLMediaData.h"

#import "TLMessageLogUserDefaultsStorage.h"

static NSString *const kStorageKey = @"TLMessageLogStorage";
static NSString *const kMessageKey = @"message";
static NSString *const kJIDKey = @"jid";
static NSString *const kDisplayNameKey = @"displayName";
static NSString *const kPhotoKey = @"photo";
static NSString *const kReceivedKey = @"received";
static NSString *const kUnreadKey = @"unread";
static NSString *const kDateKey = @"date";
static NSString *const kMediaDataKey = @"mediaData";

@interface TLMessageLogUserDefaultsStorage()

@property (nonatomic, strong) NSMutableArray *storageMessages;

- (void)loadFromStorage;
- (void)saveToStorage;
@end

@implementation TLMessageLogUserDefaultsStorage

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil) {
        self.storageMessages = [[NSMutableArray alloc] init];
        [self loadFromStorage];
    }
    return self;
}

#pragma mark -
#pragma mark <TLMessageLogStorage>

- (NSArray *)messages
{
    return self.storageMessages;
}

- (NSArray *)messagesForBuddy:(TLBuddy *)buddy
{
    return [[self messages] filteredArrayUsingPredicate:
        [NSPredicate predicateWithFormat:@"buddy.accountName like %@",
        buddy.accountName]];
}

- (NSArray *)messagesForBuddy:(TLBuddy *)buddy
               sortDescriptors:(NSArray *)sortDescriptors
{
    return [[self messagesForBuddy:buddy]
       sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSArray *)messagesForBuddyAccountName:(NSString *)accountName
               sortDescriptors:(NSArray *)sortDescriptors
{
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"buddy.accountName like %@",
        accountName];

    return [[[self messages] filteredArrayUsingPredicate:predicate]
        sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSArray *)messagesWithSortDescriptors:(NSArray *)sortDescriptors
{
    return [[self messages] sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSInteger)countUnreadMessagesForBuddy:(TLBuddy *)buddy
{
    NSPredicate *predicate = [NSPredicate 
        predicateWithFormat:@"(buddy.accountName like %@) AND (unread == YES)",
        buddy.accountName];

    return [[[self messages] filteredArrayUsingPredicate:predicate] count];
}

- (NSArray *)buddiesByMessagesWithSortDescriptors:(NSArray *)sortDescriptors
{
    NSArray *sortedMessages =
        [self messagesWithSortDescriptors:sortDescriptors];
    NSMutableArray *buddies = [[NSMutableArray alloc] init];

    for (TLMessage *message in sortedMessages) {
        TLBuddy *buddy = message.buddy;

        if([[buddies filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"accountName like %@",
                buddy.accountName]] count] == 0)
            [buddies addObject:buddy];
    }
    return buddies;
}

- (void)setUnreadMessagesAsReadForBuddyAcountName:(NSString *)accountName
{
    NSArray *currentBuddyMessages = 
        [self messagesForBuddyAccountName:accountName
            sortDescriptors:[NSArray array]];
    for (TLMessage *message in currentBuddyMessages) {
        message.unread = NO;
    }
    [self saveToStorage];
}

- (void)addMessage:(TLMessage *)message
{
    [self.storageMessages addObject:message];
    [self saveToStorage];
}

- (void)reloadStorage
{
    [self.storageMessages removeAllObjects];
    [self loadFromStorage];
}

#pragma mark -
#pragma mark TLMessageLogUserDefaultsStorage

- (void)loadFromStorage
{
    NSArray *storedMessages =
        [[NSUserDefaults standardUserDefaults] arrayForKey:kStorageKey];
    for (NSDictionary *entry in storedMessages) {
        NSString *messageStr = [entry objectForKey:kMessageKey];
        NSString *JIDStr = [entry objectForKey:kJIDKey];
        NSString *displayName = [entry objectForKey:kDisplayNameKey];
        NSData *photo = [entry objectForKey:kPhotoKey];
        BOOL received = [[entry objectForKey:kReceivedKey] boolValue];
        BOOL unread = [[entry objectForKey:kUnreadKey] boolValue];
        NSDate *date = [entry objectForKey:kDateKey];
        NSData *mediaData = [entry objectForKey:kMediaDataKey];
        TLBuddy *buddy = [TLBuddy buddyWithDisplayName:displayName
            accountName:JIDStr];

        if (photo != nil) {
            buddy.photo = photo;
        }

        TLMessage *message = [TLMessage messageWithBuddy:buddy
            message:messageStr received:received unread:unread];

        if (mediaData != nil) {
            message.mediaData = [TLMediaData mediaDataWithData:mediaData];
        }
        

        buddy.lastMessage = message;

        message.date = date;
        [self.storageMessages addObject:message];
    }
}

- (void)saveToStorage
{
    NSMutableArray *messagesToStore = [NSMutableArray array]; 

    for (TLMessage *message in self.storageMessages) {
        NSMutableDictionary *entry =
            [NSMutableDictionary dictionaryWithDictionary:@{
                kMessageKey: message.message,
                kJIDKey: message.buddy.accountName,
                kDisplayNameKey: message.buddy.displayName,
                kReceivedKey: [NSNumber numberWithBool:message.received],
                kUnreadKey: [NSNumber numberWithBool:message.unread],
                kDateKey:message.date
        }];
        if (message.buddy.photo != nil) {
            [entry setObject:message.buddy.photo forKey:kPhotoKey];
        }
        if (message.mediaData != nil) {
            NSData *mediaDataRaw = [message.mediaData getObjectData];
            [entry setObject:mediaDataRaw forKey:kMediaDataKey];
        }
        [messagesToStore addObject:entry];
    }
    [[NSUserDefaults standardUserDefaults] setObject:messagesToStore
        forKey:kStorageKey];
    //send a notifacation for update the chat history
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLNewMessageNotification
        object:self];
}

#pragma mark -
#pragma mark <TLMessageLogStorageTesting>

- (void)setFixture:(NSArray *)fixture
{
    fixture = fixture;
    [[NSUserDefaults standardUserDefaults] setObject:fixture forKey:kStorageKey];
    [self reloadStorage];
}
@end
