#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TLHitForwardingViewDelegate;

@interface TLHitForwardingView: UIView

- (id)initWithUnderlyingView:(UIView *)view
                    delegate:(id<TLHitForwardingViewDelegate>)delegate;
- (void)showWithEdgeInsets:(UIEdgeInsets)theEdgeInsets
               orientation:(UIInterfaceOrientation)orientation;
- (void)hide;
@end

@protocol TLHitForwardingViewDelegate <NSObject>

- (void)hitForwardingView:(TLHitForwardingView *)view
          wasHitWithPoint:(CGPoint)point
                    event:(UIEvent *)event;
@end
