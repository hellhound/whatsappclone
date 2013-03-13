#import "TLHitForwardingView.h"

@interface TLHitForwardingView ()

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, weak) id<TLHitForwardingViewDelegate> delegate;

- (void)resize;

@end

@implementation TLHitForwardingView

#pragma mark -
#pragma mark UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    [self resize];
    
    BOOL isInside = [super pointInside:point withEvent:event];

    if (isInside)
        [delegate hitForwardingView:self wasHitWithPoint:point event:event];
    return isInside;
}

#pragma mark -
#pragma mark TLHitForwardingView

@synthesize view;
@synthesize edgeInsets;
@synthesize delegate;

- (id)initWithUnderlyingView:(UIView *)theView
                    delegate:(id<TLHitForwardingViewDelegate>)theDelegate
{
    if ((self = [super init]) != nil) {
        self.view = theView;
        self.delegate = theDelegate;
    }
    return self;
}

- (void)showWithEdgeInsets:(UIEdgeInsets)theEdgeInsets
               orientation:(UIInterfaceOrientation)theOrientation
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    self.edgeInsets = theEdgeInsets;
    self.orientation = theOrientation;

    if ([window.subviews count] > 0) {
        [window addSubview:self];
        [self resize];
        [window bringSubviewToFront:self];
   }
}

- (void)hide
{
    [self removeFromSuperview];
}

- (void)resize
{
    CGRect viewFrame = self.view.frame;
    CGRect viewBounds = self.view.bounds;
    CGPoint origin = CGPointZero;
    CGSize size = CGSizeZero;
    
    origin.x = viewFrame.origin.x + self.edgeInsets.left;
    origin.y = viewFrame.origin.y + self.edgeInsets.top; 
    size.width = viewBounds.size.width - self.edgeInsets.right;
    size.height = viewBounds.size.height - self.edgeInsets.bottom;
    self.frame = CGRectMake(
        origin.x,
        origin.y,
        size.width,
        size.height);
}
@end
