#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TLTMojiCategoryBarDelegate;

@interface TLTMojiCategoryBar: UIScrollView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame
           delegate:(id<TLTMojiCategoryBarDelegate>)delegate;
@end

@protocol TLTMojiCategoryBarDelegate <NSObject>

@required

- (NSOrderedSet *)categoryBarWillPresentCategories:
    (TLTMojiCategoryBar *)categoryBar;
- (void)        category:(TLTMojiCategoryBar *)categoryBar
      wasTappedWithImage:(UIImage *)image;
@end
