#import <dispatch/dispatch.h>
#import <UIKit/UIKit.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import <XMPPFramework.h>
#import <DDLog.h>
#import <DDTTYLogger.h>

#import "Application/TLConstants.h"
#import "Services/Models/TLAccount.h"
#import "Services/Models/TLBuddy.h"
#import "Services/Models/TLMessage.h"
#import "Managers/AccountManager/TLAccountManager.h"
#import "Managers/MessageLog/TLMessageLogManager.h"
#import "TLXMPPManager.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation NSData (Md5)
 
-(NSString*)md5{
	const char *cStr = [self bytes];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, [self length], digest );
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
}

 

@end

@interface TLXMPPManager()
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, assign) BOOL isXmppConnected;
@property (nonatomic, assign) BOOL updateMyVcard;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSMutableArray *turnSockets;
@property (nonatomic, strong) NSData *sendData;
@property (nonatomic, assign) BOOL *isSending;

- (void)setupStream;
- (void)teardownStream;
- (void)connectWithJID:(NSString *)JID password:(NSString *)password;
- (void)goOnline;
- (void)goOffline;
- (void)failedToConnect;
- (TLBuddy *)buddyWithMessage:(XMPPMessage *)message;
- (void)updateBuddyWithVCard:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid;
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;
-(void)upload:(NSData*)dataToUpload
     inBucket:(NSString*)bucket forKey:(NSString*)key;
@end

@implementation TLXMPPManager

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil) {
        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        // Setup the XMPP stream
        [self setupStream];
        self.buddyList = [[TLBuddyList alloc] init];
        // conf notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(applicationWillResignActiveNotification:)
            name:UIApplicationWillResignActiveNotification object:nil];

		// Initialize other stuff
		
		self.turnSockets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self teardownStream];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark -
#pragma mark <TLProtocol>

- (void)sendMessage:(TLMessage *)theMessage
{
    NSString *messageStr = theMessage.message;
    
    if ([messageStr length] > 0) 
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];

        [body setStringValue:messageStr];

        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:
            theMessage.buddy.accountName];
        [message addAttributeWithName:@"id" stringValue:
            [[NSUUID UUID] UUIDString]];
        
        NSXMLElement * receiptRequest =
            [NSXMLElement elementWithName:@"request"];

        [receiptRequest addAttributeWithName:@"xmlns"
            stringValue:@"urn:xmpp:receipts"];
        [message addChild:receiptRequest];
        [message addChild:body];
        [self.bridge sendMessageBridge:message];
        [self.storage addMessage:theMessage];
    }
}

- (void)sendViaMedia:(TLMessage *)theMessage
{
    TLMediaData *media = theMessage.mediaData;
    
    if (media != nil) 
    {
        self.sendData = [media getObjectData];
        NSString *md5Hash = [self.sendData md5];
        NSString *messageKey = [NSString stringWithFormat:@"#%@#",
             md5Hash];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
            (unsigned long)NULL), ^(void) {
                [self upload:self.sendData inBucket:TL_AMAZON_S3_CURRENT_BUCKET
                      forKey:md5Hash];
            });
        self.isSending = YES;
        theMessage.message = messageKey;
        [self sendMessage:theMessage];
    }
}

-(void)upload:(NSData*)dataToUpload
     inBucket:(NSString*)bucket forKey:(NSString*)key
{
    @try {	
        AmazonS3Client *s3 = [[AmazonS3Client alloc]
            initWithAccessKey:TL_AMAZON_AWS_ACCESS_KEY
            withSecretKey:TL_AMAZON_AWS_SECRET_KEY];
        S3CreateBucketRequest *cbr = [[S3CreateBucketRequest alloc]
            initWithName:bucket];		
        [s3 createBucket:cbr];
				
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:key
                inBucket:bucket];        

        // The S3UploadInputStream was deprecated after the release of iOS6.
        S3UploadInputStream *stream = 
            [S3UploadInputStream inputStreamWithData:dataToUpload];  
        stream.delay = 0.2; // In seconds
        stream.packetSize = 16; // Number of 1K blocks
        
        por.contentLength = [dataToUpload length];
        por.stream = stream;
        
        [s3 putObject:por];
    }
    @catch ( AmazonServiceException *exception ) {
        NSLog( @"Upload Failed, Reason: %@", exception );
    }	
}


- (void)connectWithPassword:(NSString *)thePassword
{
    [self connectWithJID:[self.account getUUID] password:thePassword];
}

- (void)disconnect
{
    [self goOffline];
    [self.xmppStream disconnect];
    /*
    [self.xmppRosterStorage
        clearAllUsersAndResourcesForXMPPStream:self.xmppStream];
    */
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLProtocolLogoutNotification
        object:self];
}

- (void)updateAccountDataWithTLAccount
{
    self.updateMyVcard = YES;
    [self.xmppvCardTempModule fetchvCardTempForJID:self.xmppStream.myJID];
}

#pragma mark -
#pragma mark <TLProtocolBridge>

- (void)sendMessageBridge:(NSXMLElement *)message
{
    [self.xmppStream sendElement:message];
}

- (bool)connectBridge:(NSError **)error
{
    return [self.xmppStream connect:error];
}

#pragma mark -
#pragma mark <XMPPStreamDelegate>

- (void)xmppStream:(XMPPStream *)sender
  socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    NSError *error = nil;

    if (![self.xmppStream authenticateWithPassword:self.password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
        self.isXmppConnected = NO;
        return;
    }
    self.isXmppConnected = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self failedToConnect];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if ([message isChatMessageWithBody])
    {
        NSString *body = [[message elementForName:@"body"] stringValue];
        TLBuddy *buddy = [self buddyWithMessage:message];
        // Parse the message
        TLMessage *incomingMessage =
            [TLMessage messageWithBuddy:buddy message:body];

        [buddy receiveMessage:incomingMessage];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kTLMessageReceivedNotification
            object:self userInfo:@{@"message": incomingMessage}];
        [self.storage addMessage:incomingMessage];
    }
}

- (void)    xmppStream:(XMPPStream *)sender
    didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@\nType: %@\nShow: %@\nStatus: %@", THIS_FILE,
        THIS_METHOD, [presence from], [presence type], [presence show],
        [presence status]);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLStatusUpdateNotification
        object:self userInfo:@{@"user": [[presence from] bare]}];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLProtocolDisconnectNotification object:self];
    if (!self.isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect];
    }
}

#pragma mark -
#pragma mark <XMPPRosterMemoryStorageDelegate>

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    for (XMPPUserMemoryStorageObject *user in [sender sortedUsersByName]) {
        TLBuddy *buddy = [TLBuddy buddyWithDisplayName:[user displayName]
            accountName:[[user jid] bare]];

        [self.buddyList addBuddy:buddy];
        //populate the vcard for buddy

        XMPPvCardTemp *vCardTemp = [self.xmppvCardTempModule
            fetchvCardTempForJID:[user jid]];

        if (vCardTemp != nil) {
            [self updateBuddyWithVCard:vCardTemp forJid:[user jid]];
            //call again for update the data
            //[self.xmppvCardTempModule
                //fetchvCardTempForJID:[user jid] useCache:NO];
        }
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLRosterDidPopulateNotification
        object:self userInfo:nil];
}

#pragma mark -
#pragma mark <XMPPRosterMemoryStorageDelegate>

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule 
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp 
                     forJID:(XMPPJID *)jid
{
    [self updateBuddyWithVCard:vCardTemp forJid:jid];
}
#pragma mark -
#pragma mark TLXMPPManager

@synthesize account;
@synthesize buddyList;
@synthesize storage;
@synthesize bridge;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize isXmppConnected;
@synthesize password;
@synthesize updateMyVcard;
@synthesize turnSockets;
@synthesize sendData;
@synthesize isSending;

- (id<TLMessageLogStorage>)storage
{
    @synchronized(self) {
        if (storage == nil) {
            storage = [[TLMessageLogManager sharedInstance] storage];
        }
    }
    return storage;
}

- (id<TLProtocolBridge>)bridge
{
    @synchronized(self) {
        if (bridge == nil) {
            bridge = self;
        }
    }
    return bridge;
}

- (void)setupStream
{
    NSAssert(self.xmppStream == nil,
        @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    // 
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions
    // and delegates.
    
    self.xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    // Want xmpp to run in the background?
    // 
    // P.S. - The simulator doesn't support backgrounding yet.
    //        When you try to set the associated property on the simulator,
    //        it simply fails.
    //        And when you background an app on the simulator,
    //        it just queues network traffic til the app is foregrounded
    //        again.
    //        We are patiently waiting for a fix from Apple.
    //        If you do enableBackgroundingOnSocket on the simulator,
    //        you will simply see an error message from the xmpp stack when
    //        it fails to set the property.
    self.xmppStream.enableBackgroundingOnSocket = YES;
#endif
    
    // Setup reconnect
    // 
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    // 
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or
    // use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    //NSLog(@"Unique Identifier: %@",self.account.uniqueIdentifier);
    
    //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]
    //  initWithDatabaseFilename:self.account.uniqueIdentifier];
    //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    self.xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster =
        [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    // 
    // The vCard Avatar module works in conjuction with the standard vCard Temp
    // module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to
    // cache roster photos in the roster.
    
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCardTempModule =
        [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc]
        initWithvCardTempModule:xmppvCardTempModule];
    
    // Activate xmpp modules
    
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppRoster activate:self.xmppStream];
    [self.xmppvCardTempModule activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppvCardTempModule addDelegate:self
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)teardownStream
{
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    [self.xmppvCardTempModule removeDelegate:self];
    [self.xmppReconnect deactivate];
    [self.xmppRoster deactivate];
    [self.xmppvCardTempModule deactivate];
    [self.xmppvCardAvatarModule deactivate];
    [self.xmppStream disconnect];
}

- (void)connectWithJID:(NSString *)JIDStr password:(NSString *)thePassword
{
    if (![self.xmppStream isDisconnected]) {
        // TODO should raise an exception here or err
        return;
    }
    if (JIDStr == nil || thePassword == nil) {
        // TODO should raise an exception here or err
        DDLogWarn(@"JID and password must be set before connecting!");
        return;
    }
    self.xmppStream.myJID = [XMPPJID jidWithString:JIDStr resource:nil];
    self.xmppStream.hostName = kTLHostDomain;
    self.xmppStream.hostPort = kTLHostPort;
    self.password = thePassword;
    
    NSError *error = nil;

    if (![self.bridge connectBridge:&error])
    {
        [self failedToConnect];
        DDLogError(@"Error connecting: %@", error);
    }
}

- (void)goOnline
{
    // TODO: for some reason xmppRoster.autoFetchRoster doesn't do anything
    //[self.xmppRoster fetchRoster];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLProtocolLoginSuccessNotification object:self];
    // type="available" is implicit
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:presence];
}


- (void)failedToConnect
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTLProtocolLoginFailNotification object:self];    
}

- (TLBuddy *)buddyWithMessage:(XMPPMessage *)message
{
    XMPPUserMemoryStorageObject *user =
        [self.xmppRosterStorage userForJID:[message from]];

    return [self.buddyList buddyForAccountName:[user.jid bare]];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    // Reset the roster
    self.buddyList = [[TLBuddyList alloc] init];
}

- (void)updateBuddyWithVCard:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid
{
    XMPPJID *myJid = self.xmppStream.myJID;
    if ([myJid isEqualToJID:jid options:XMPPJIDCompareUser]) {
        if (updateMyVcard == YES) { //for vcard updating
            vCardTemp.nickname = self.account.firstName;
            vCardTemp.givenName = self.account.firstName;
            vCardTemp.familyName = self.account.lastName;
            vCardTemp.photo = self.account.photo;
            updateMyVcard = NO;
            [self.xmppvCardTempModule updateMyvCardTemp:vCardTemp];
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kTLProtocolVcardSuccessSaveNotification
                object:self];
            [[[TLAccountManager sharedInstance] storage] saveAccount:self.account];
        }
    } else {
        TLBuddy *aBuddy = [self.buddyList buddyForAccountName:[jid bare]];
        aBuddy.displayName = vCardTemp.nickname;
        aBuddy.photo = vCardTemp.photo;
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kTLDidBuddyVCardUpdatedNotification
            object:self];
    }
}
@end
