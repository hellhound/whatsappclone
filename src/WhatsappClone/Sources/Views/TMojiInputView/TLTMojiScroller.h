#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TLTMojiScrollerDelegate;

@interface TLTMojiScroller: UIView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame
           delegate:(id<TLTMojiScrollerDelegate>)delegate;
- (void)updateScroller;
@end

@protocol TLTMojiScrollerDelegate <NSObject>

- (NSOrderedSet *)scrollerWillPresentImages:(TLTMojiScroller *)scroller;
@end
