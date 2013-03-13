#import "UIImage+TL568h.h"

@implementation UIImage (TL568h)

#pragma mark -
#pragma mark UIImage (TL568h)

+ (UIImage *)imageNamed568h:(NSString *)imageNamed
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    NSString *resultingName = imageNamed;

    if (screenScale == 2.f && screenHeight == 568.f)
        resultingName = [resultingName stringByAppendingString:@"-568h"];
    return [UIImage imageNamed:resultingName];
}
@end
