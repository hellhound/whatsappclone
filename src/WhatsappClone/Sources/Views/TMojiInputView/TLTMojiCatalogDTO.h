#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLTMojiCatalogDTO: NSObject

@property (nonatomic, strong) UIImage *catalogIcon;
@property (nonatomic, assign) NSUInteger tag;

- (void)SetTMojiFilenames:(NSOrderedSet *)filenames;
- (NSString *)getNameForTMojiImage:(UIImage *)image;
- (NSOrderedSet *)getTMojiIcons;
@end
