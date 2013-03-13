#import "Application/TLConstants.h"
#import "Services/Models/TLMessage.h"
#import "XMPP/TLXMPPManager.h"
#import "TLProtocolManager.h"

static __strong TLProtocolManager *kSharedManager = nil;

@interface TLProtocolManager(Private)

@property (nonatomic, strong) id<TLProtocol> protocol;
@end

@implementation TLProtocolManager

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
    kTLSendMessageNotification object:nil];
}

- (id)init
{
    if ((self = [super init]) != nil) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(sendMessage:)
            name:kTLSendMessageNotification
            object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Singleton methods

+ (TLProtocolManager *)sharedInstance
{
    @synchronized (self) {
        if (kSharedManager == nil)
            kSharedManager = [[super allocWithZone:nil] init];
    }
    return kSharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (kSharedManager == nil)
            kSharedManager = [super allocWithZone:zone];
            return kSharedManager;
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark TLProtocolManager

@synthesize protocol;

+ (void)replaceInstance:(TLProtocolManager *)instance
{
    kSharedManager = instance;
}

- (id<TLProtocol>)protocol
{
    @synchronized (self) {
        if (protocol == nil) {
            protocol = [[TLXMPPManager alloc] init];
        }
    }
    return protocol;
}
@end
