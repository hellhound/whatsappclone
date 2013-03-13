#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLRegistrationBaseViewController: UIViewController

@property (nonatomic, strong) UIView *containerView;

// Setup methods
- (void)addView:(UIView *)view; // Adds the view to the container
- (void)viewSetup;
- (UIResponder *)getFirstResponder;
- (CGFloat)getContainerXOriging;
- (CGFloat)getContainerYOriging;
- (void)containerSetup;
- (Class)getContainerClass;
- (CGRect)getContainerBounds;
- (void)didCalculateBounds:(CGRect)bounds;
// Navigation bar setup methods
- (id)getBackActionTarget;
- (id)getForwardActionTarget;
- (SEL)getBackActionSelector;
- (SEL)getForwardActionSelector;
- (UIBarButtonItem *)getButtonItemForIcon:(NSString *)icon
                                   target:(id)target
                                 selector:(SEL)selector;
- (UIImageView *)getTitleImageView;
@end
