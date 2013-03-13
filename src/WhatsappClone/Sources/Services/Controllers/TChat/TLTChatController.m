#import "Application/TLConstants.h"

#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Services/Models/TLMediaData.h"
#import "Services/Models/TLMessage.h"

#import "TLTChatController.h"

// Define needed UIKit notifications as we are not linking to UIKit.framework
static NSString *const kUIKeyboardWillShowNotification =
    @"UIKeyboardWillShowNotification";
static NSString *const kUIKeyboardWillHideNotification =
    @"UIKeyboardWillHideNotification";
static NSString *const kUIApplicationWillResignActiveNotification =
    @"UIApplicationWillResignActiveNotification";

@interface TLTChatController()

@property (nonatomic, strong) NSMutableArray *messageLog;
@property (nonatomic, weak) id<TLTChatControllerDelegate> delegate;

- (void)sendMessage:(NSString *)message accountName:(NSString *)accountName
        displayName:(NSString *)displayName;

- (void)sendMedia:(TLMediaData *)mediaData accountName:(NSString *)accountName
        displayName:(NSString *)displayName;

// Notifications
- (void)receivedMessageNotification:(NSNotification *)notification;
- (void)updateVcardNotification:(NSNotification *)notification;
- (void)keyboardWillShowNotification:(NSNotification *)notification;
- (void)keyboardWillHideNotification:(NSNotification *)notification;
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;
@end

@implementation TLTChatController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kUIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kUIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kUIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLDidBuddyVCardUpdatedNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

- (id)initWithDelegate:(id<TLTChatControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil) {
        self.messageLog = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(receivedMessageNotification:)
            name:kTLMessageReceivedNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(keyboardWillShowNotification:)
            name:kUIKeyboardWillShowNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(keyboardWillHideNotification:)
            name:kUIKeyboardWillHideNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(applicationWillResignActiveNotification:)
            name:kUIApplicationWillResignActiveNotification
            object:nil];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(updateVcardNotification:)
            name:kTLDidBuddyVCardUpdatedNotification
            object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark TLChatController

@synthesize delegate;
@synthesize messageLog;

- (void)populateMessagesForBuddyAccountName:(NSString *)accountName
{
    //obtained from storage
    NSArray  *dateSort =
        [NSArray arrayWithObject:[NSSortDescriptor
        sortDescriptorWithKey:@"date" ascending:NO]];
    id<TLMessageLogStorage> logStorage = 
        [[TLMessageLogManager sharedInstance] storage];

    self.messageLog = [NSMutableArray arrayWithArray:
        [logStorage messagesForBuddyAccountName:accountName
        sortDescriptors:dateSort]];

    [self setMessagesAsRead];
}

- (NSData *)getAvatarForAccountName:(NSString *)accountName
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    TLBuddy *buddy = [[manager buddyList] buddyForAccountName:accountName];
    return [buddy photo];
}

- (NSInteger)messageLogCount
{
    return [self.messageLog count];
}

- (NSDictionary *)messageAtIndex:(NSInteger)index
{
    TLMessage *message = [self.messageLog objectAtIndex:index];
    NSNumber *ownership = [NSNumber numberWithBool:message.received];

    NSMutableDictionary *arrayTemp = [NSMutableDictionary
        dictionaryWithDictionary:@{
        @"displayName": message.buddy.displayName,
        @"message": message.message,
        @"date": message.date,
        @"ownership": ownership,
        @"isTmoji":[NSNumber numberWithBool:[message isATmojiMessage]],
        @"isMedia":[NSNumber numberWithBool:[message isAMediaMessage]],
    }];

    if ([message mediaData] != nil) {
        [arrayTemp setObject:[message mediaData] forKey:@"mediaData"];
    }
    return arrayTemp;
}

- (void)setMessagesAsRead
{
    id<TLMessageLogStorage> logStorage = 
        [[TLMessageLogManager sharedInstance] storage];
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    [logStorage setUnreadMessagesAsReadForBuddyAcountName:accountName];
}

- (void)sendMessage:(NSString *)message accountName:(NSString *)accountName
        displayName:(NSString *)displayName
{
    //getting the buddy id of the conversation
    NSString *buddyJID = accountName;
    TLBuddy *destinationBuddy = [TLBuddy
        buddyWithDisplayName:displayName accountName:buddyJID];
    //creating a new TLMessage
    TLMessage *newMessage = [TLMessage messageWithBuddy:destinationBuddy
        message:message received:NO unread:NO];

    [newMessage send];
    [self.messageLog addObject:newMessage];
}

- (void)sendMedia:(TLMediaData *)mediaData accountName:(NSString *)accountName
        displayName:(NSString *)displayName
{
    //getting the buddy id of the conversation
    NSString *buddyJID = accountName;
    TLBuddy *destinationBuddy = [TLBuddy
        buddyWithDisplayName:displayName accountName:buddyJID];
    //creating a new TLMessage
    TLMessage *newMessage = [TLMessage messageWithBuddy:destinationBuddy
        mediaData:mediaData received:NO unread:NO];

    [newMessage send];
    [self.messageLog addObject:newMessage];
}

#pragma mark -
#pragma mark Actions

- (void)backButtonAction
{
    [self.delegate controllerGotBackButtonAction:self];
}

- (void)tmojiButtonAction
{
    [self.delegate controllerGotTmojiButtonAction:self];
}

- (void)mediaButtonAction
{
    [self.delegate controllerGotMediaButtonAction:self];
}

- (void)sendTextMessage
{
    if ([self.delegate controllerNeedMessageLength:self] > 0) {
        NSString *message = [self.delegate controllerNeedMessageText:self];
        NSString *accountName = [self.delegate controllerNeedAccountName:self];
        NSString *displayName = [self.delegate controllerNeedDisplayName:self];
        [self sendMessage:message accountName:accountName
              displayName:displayName];
        [self.delegate controllerDidSendMessage:self];
    }
}

- (void)sendTmojiImage:(NSString *)imageName
{
    NSString *message = [NSString stringWithFormat:@"%@%@%@", kTLTMojiSymbol,
        imageName, kTLTMojiSymbol];
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    NSString *displayName = [self.delegate controllerNeedDisplayName:self];
    [self sendMessage:message accountName:accountName
          displayName:displayName];
    [self.delegate controllerDidSendMessage:self];
}

- (void)sendMediaPhoto:(NSData *)imageData
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    NSString *displayName = [self.delegate controllerNeedDisplayName:self];
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    mediaData.mediaType = kMessageMediaPhoto;
    mediaData.data = imageData;
    [self sendMedia:mediaData accountName:accountName
          displayName:displayName];
    [self.delegate controllerDidSendMessage:self];
}

- (void)sendMediaVideo:(NSData *)videoData
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    NSString *displayName = [self.delegate controllerNeedDisplayName:self];
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    mediaData.mediaType = kMessageMediaVideo;
    mediaData.data = videoData;
    [self sendMedia:mediaData accountName:accountName
          displayName:displayName];
    [self.delegate controllerDidSendMessage:self];
}

#pragma mark -
#pragma mark Notifications

- (void)receivedMessageNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *message = [userInfo objectForKey:@"message"];

    [self.messageLog addObject:message];
    [self.delegate controllerDidReceivedMessage:self];
    [self setMessagesAsRead];
}

- (void)updateVcardNotification:(NSNotification *)notification
{
    [self.delegate controllerDidUpdateAvatar:self];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self.delegate controller:self
        keyboardWillShowWithUserInfo:[notification userInfo]];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self.delegate controller:self
        keyboardWillHideWithUserInfo:[notification userInfo]];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    [self.delegate controllerDidReceivedResignedActive:self];
}
@end
