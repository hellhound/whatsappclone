#import "TLTMojiCatalogDTO.h"

@interface TLTMojiCatalogDTO()

@property (nonatomic, strong) NSMutableOrderedSet *TMojiIcons;
@property (nonatomic, strong) NSOrderedSet *TMojiNames;
@end

@implementation TLTMojiCatalogDTO

#pragma mark -
#pragma mark TLTMojiCatalogDTO

@synthesize catalogIcon;

#pragma mark -
#pragma mark TLTMojiCatalogDTO()
@synthesize TMojiIcons, TMojiNames;
- (void)SetTMojiFilenames:(NSOrderedSet *)filenames;
{
    TMojiNames = filenames;
    TMojiIcons = [NSMutableOrderedSet orderedSet];
    for (NSString *filename in filenames) {
        [TMojiIcons addObject:[UIImage imageNamed:filename]]; 
    }
}

- (NSString *)getNameForTMojiImage:(UIImage *)image
{
    NSUInteger index = [TMojiIcons indexOfObject:image];
    NSString *filename = [TMojiNames objectAtIndex:index];
    return filename;
}

- (NSOrderedSet *)getTMojiIcons
{
    return TMojiIcons;
}

@end
