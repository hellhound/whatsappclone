#import "NSString+TLAdditions.h"

@implementation NSString (TLAdditions)

#pragma mark -
#pragma mark NSString (TLAdditions)

- (NSString *)substringForLimit:(NSUInteger)limit
{
    NSUInteger length = [self length];

    return [self substringToIndex:(length > limit ? limit : length)];
}
@end
