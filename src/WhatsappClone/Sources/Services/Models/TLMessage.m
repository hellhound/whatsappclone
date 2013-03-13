#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import "Application/TLConstants.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "TLMessage.h"

@interface TLMessage()

@property (nonatomic, strong) id<TLProtocol> messageProtocol;

- (id)initWithBuddy:(TLBuddy *)theBuddy
            message:(NSString *)theMessage
          mediaData:(TLMediaData *)theMediaData
           received:(BOOL)beenReceived
             unread:(BOOL)beenUnread;
- (void)getMediaDataFromAWS;
@end

@implementation TLMessage

#pragma mark -
#pragma mark TLMessage

@synthesize message, mediaData, buddy, date, messageProtocol;

- (NSString *)message
{
    if (message == nil) {
         message = @"";
    }
    return message;
}

- (TLMediaData *)mediaData
{
    if ([self isAMediaMessage] && mediaData == nil) {
        [self getMediaDataFromAWS];
    }
    return mediaData;
}

- (id<TLProtocol>)messageProtocol
{
    if (messageProtocol == nil) {
        messageProtocol = [[TLProtocolManager sharedInstance] protocol];
    }
    return messageProtocol;
}

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy message:(NSString *)message
{
    return [[self alloc] initWithBuddy:buddy message:message];
}

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                        message:(NSString *)message
                       received:(BOOL)received
{
    return [[self alloc] initWithBuddy:buddy message:message
        received:received unread:YES];
}

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                        message:(NSString *)message
                       received:(BOOL)received
                       unread:(BOOL)unread
{
    return [[self alloc] initWithBuddy:buddy message:message
        received:received unread:unread];
}

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                      mediaData:(TLMediaData *)mediaData
                       received:(BOOL)received
                         unread:(BOOL)unread
{
    return [[self alloc] initWithBuddy:buddy message:nil mediaData:mediaData
        received:received unread:unread];
}

- (id)initWithBuddy:(TLBuddy *)theBuddy message:(NSString *)theMessage
{
    return
        (self = [self initWithBuddy:theBuddy message:theMessage
            received:YES unread:YES]);
}

- (id)initWithBuddy:(TLBuddy *)theBuddy
            message:(NSString *)theMessage
           received:(BOOL)beenReceived
             unread:(BOOL)beenUnread
{
    if ((self = [super init]) != nil) {
        self.buddy = theBuddy;
        self.message = theMessage;
        self.received = beenReceived;
        self.unread = beenUnread;
        self.date = [NSDate date];
    }
    return self;
}

- (BOOL)isATmojiMessage
{
    NSUInteger currentLength = [self.message length];
    if (currentLength > 1 && [[self.message substringToIndex:1]
            isEqualToString:kTLTMojiSymbol] &&
            [[self.message substringFromIndex:currentLength -1]
            isEqualToString:kTLTMojiSymbol]) {
        return YES;
    }
    return NO;
}

- (BOOL)isAMediaMessage
{
    NSUInteger currentLength = [self.message length];
    if (currentLength > 1 && [[self.message substringToIndex:1]
            isEqualToString:@"#"] &&
            [[self.message substringFromIndex:currentLength -1]
            isEqualToString:@"#"]) {
        return YES;
    }
    return NO;
}

- (NSString *)mediaDescription
{
    NSString *mediaString = @"media";
    if (self.mediaData != nil) {
        if (self.mediaData.mediaType == kMessageMediaPhoto) {
            return @"photo";
        } else {
            return @"video";
        }
    }
    return mediaString;
}

- (void)send
{
    if (self.mediaData != nil) {
        [self.messageProtocol sendViaMedia:self];
        return;
    }
    [self.messageProtocol sendMessage:self];
}

#pragma mark -
#pragma mark TLMessage(private)

- (id)initWithBuddy:(TLBuddy *)theBuddy
            message:(NSString *)theMessage
          mediaData:(TLMediaData *)theMediaData
           received:(BOOL)beenReceived
             unread:(BOOL)beenUnread
{
    if ((self = [super init]) != nil) {
        self.buddy = theBuddy;
        self.message = theMessage;
        self.mediaData = theMediaData;
        self.received = beenReceived;
        self.unread = beenUnread;
        self.date = [NSDate date];
    }
    return self;
}

- (void)getMediaDataFromAWS
{
    NSUInteger currentLength = [self.message length];
    NSRange range = NSMakeRange(1, currentLength -2);
    NSString *mediaDataName = [self.message substringWithRange:range];
    NSString *bucketName = TL_AMAZON_S3_CURRENT_BUCKET;
    NSString *filePath = [NSTemporaryDirectory()
        stringByAppendingPathComponent:mediaDataName];
    @try {	
        AmazonS3Client *s3 = [[AmazonS3Client alloc]
            initWithAccessKey:TL_AMAZON_AWS_ACCESS_KEY
            withSecretKey:TL_AMAZON_AWS_SECRET_KEY];

        NSOutputStream *stream = [[NSOutputStream alloc]
            initToFileAtPath:filePath append:NO];
        [stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        [stream open];
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc]
            initWithKey:mediaDataName withBucket:bucketName];
        request.outputStream = stream;
        [s3 getObject:request];
        [stream close];

        //load into tlmessage
        TLMediaData *tempData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        self.mediaData = tempData;
        [s3 deleteObjectWithKey:mediaDataName withBucket:bucketName];
    }
    @catch ( AmazonServiceException *exception ) {
        NSLog( @"Download Failed, Reason: %@", exception );
    }	
}

#pragma mark -
#pragma mark Test

- (id)initWithProtocol:(id<TLProtocol>)protocol
{
    if ((self = [super init]) != nil) {
        self.messageProtocol = protocol;
    }
    return self;
}
@end
