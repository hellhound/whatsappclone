#import "Storage/TLMessageLogUserDefaultsStorage.h"
#import "TLMessageLogManager.h"

static TLMessageLogManager *sharedManager = nil;

@interface TLMessageLogManager(Private)

@property (nonatomic, strong) id<TLMessageLogStorage> storage;
@end

@implementation TLMessageLogManager

#pragma mark -
#pragma mark Singleton methods

+ (TLMessageLogManager *)sharedInstance
{
    @synchronized (self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (sharedManager == nil)
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark TLMessageLogManager

@synthesize storage;

- (id<TLMessageLogStorage>)storage
{
    @synchronized (self) {
        if (storage == nil) {
            storage = [[TLMessageLogUserDefaultsStorage alloc] init];
        }
    }
    return storage;
}
@end
