#import <stdlib.h>
#import <math.h>

#import "UIImage+RandomAvatar.h"

static unsigned int avatarCount = 11;

@implementation UIImage (RandomAvatar)

+ (UIImage *)randomAvatar
{
    
    NSUInteger normalized =
        ((double)(arc4random() * 1. / pow(2., sizeof(u_int32_t) * 8.))
        * (double)avatarCount) + 1;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    [formatter setPaddingCharacter:@"0"];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    [formatter setMinimumIntegerDigits:2];

    NSString *resource = [[formatter stringFromNumber:
        [NSNumber numberWithUnsignedInteger:normalized]]
        stringByAppendingString:@".jpg"];
    UIImage *image = [UIImage imageNamed:resource];
    
    //UIImage *image = [UIImage imageNamed:@"05.jpg"];
    return image;
}
@end
