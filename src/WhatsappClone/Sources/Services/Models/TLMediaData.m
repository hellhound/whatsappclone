#import "TLMediaData.h"

@implementation TLMediaData

static NSString *const kMediaTypeKey = @"mediaTypeKey";
static NSString *const kDataKey = @"dataKey";

#pragma mark -
#pragma mark <NSCoding>

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:mediaType forKey:kMediaTypeKey];
    [coder encodeObject:data forKey:kDataKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]) != nil) {
        self.mediaType = [coder decodeIntForKey:kMediaTypeKey];
        self.data = [coder decodeObjectForKey:kDataKey];
    }
    return self;
}

#pragma mark -
#pragma mark TLMediaData

@synthesize mediaType, data;

+ (TLMediaData *)mediaDataWithData:(NSData *)theData
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:theData];
}

- (NSData *)getObjectData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}
@end
