#import "Managers/AccountManager/Storage/TLAccountUserDefaultsStorage.h"
#import "TLAccountManager.h"

static __strong TLAccountManager *kSharedInstance = nil;
static __strong id<TLAccountStorage> kSharedStorage = nil;

@interface TLAccountManager()

+ (Class)accountStorageClass;
@end

@implementation TLAccountManager

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil)
        // Load the account from the start
        [self.storage getAccount];
    return self;
}

#pragma mark -
#pragma mark Singleton methods

+ (TLAccountManager *)sharedInstance
{
    @synchronized(self) {
        if (kSharedInstance == nil)
            kSharedInstance = [[super allocWithZone:nil] init];
    }
    return kSharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (kSharedInstance == nil) {
            kSharedInstance = [super allocWithZone:zone];
            return kSharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark TLAccountManager

@synthesize storage;

+ (void)replaceInstance:(TLAccountManager *)instance
{
    kSharedInstance = nil;
}

+ (id<TLAccountStorage>)storage
{
    @synchronized (self) {
        if (kSharedStorage == nil)
            kSharedStorage = [[[self accountStorageClass] alloc] init];
    }
    return kSharedStorage;
}

+ (void)setStorage:(id<TLAccountStorage>)storage
{
    kSharedStorage = storage;
}

+ (Class)accountStorageClass
{
    return [TLAccountUserDefaultsStorage class];
}

- (id<TLAccountStorage>)storage
{
    @synchronized (self) {
        if (storage == nil) {
            storage = [[self class] storage];
        }
    }
    return storage;
}
@end
