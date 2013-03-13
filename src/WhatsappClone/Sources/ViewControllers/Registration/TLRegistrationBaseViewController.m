#import "Application/TLConstants.h"
#import "Categories/UIKit/UIImage+TL568h.h"
#import "TLConfirmCodeViewController.h"
#import "TLRegistrationBaseViewController.h"

static const CGFloat kCenteredOrigin;

@interface TLRegistrationBaseViewController ()

@property (nonatomic, assign) BOOL isNavigationItemAlreadySetUp;
@property (nonatomic, strong) NSMutableArray *views;

// Everything else
- (void)focusOnControls;
// Actions
- (void)popControllerAction;
@end

@implementation TLRegistrationBaseViewController

#pragma mark -
#pragma mark UIViewController

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = super.navigationItem;

    if (!self.isNavigationItemAlreadySetUp) {
        id backTarget = [self getBackActionTarget];
        SEL backSelector = [self getBackActionSelector];
        id forwardTarget = [self getForwardActionTarget];
        SEL forwardSelector = [self getForwardActionSelector];

        navItem.titleView = [self getTitleImageView];
        navItem.leftBarButtonItem =
            [self getButtonItemForIcon:TL_BACK_ICON target:backTarget
            selector:backSelector];
        navItem.rightBarButtonItem =
            [self getButtonItemForIcon:TL_FORWARD_ICON target:forwardTarget
            selector:forwardSelector];
        self.isNavigationItemAlreadySetUp = YES;
    }
    return navItem;
}

- (void)viewDidLoad
{
    [self viewSetup];
    [self containerSetup];
    [self focusOnControls];
}

#pragma mark -
#pragma mark TLCTLConfirmCodeViewController

@synthesize isNavigationItemAlreadySetUp;
@synthesize views;
@synthesize containerView;

- (NSMutableArray *)views
{
    if (views == nil)
        views = [NSMutableArray array];
    return views;
}

- (UIView *)containerView
{
    if (containerView == nil)
        containerView = [[[self getContainerClass] alloc]
            initWithFrame:CGRectZero];
    return containerView;
}


- (Class)getContainerClass
{
    return [UIView class];
}

- (CGRect)getContainerBounds
{
    return CGRectZero;
}

- (void)focusOnControls
{
    UIResponder *responder = [self getFirstResponder];

    [responder becomeFirstResponder];
}

- (void)addView:(UIView *)view
{
    [self.views addObject:view];
}

- (void)viewSetup
{
    NSString *imageNamed = kTLPhoneFormViewControllerBackgroundImage;
    UIImage *background = [UIImage imageNamed568h:imageNamed];
    UIImageView *backgroundView =
        [[UIImageView alloc] initWithImage:background];
    CGRect navBarBounds = self.navigationController.navigationBar.bounds;
    CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
    CGRect frame = CGRectMake(.0, .0, screenBounds.size.width,
        screenBounds.size.height - navBarBounds.size.height);

    [backgroundView sizeToFit];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
    self.view.frame = frame;
}

- (UIResponder *)getFirstResponder
{
    return nil;
}

- (CGFloat)getContainerXOriging
{
    return kCenteredOrigin;
}

- (CGFloat)getContainerYOriging
{
    return kCenteredOrigin;
}

- (void)containerSetup
{
    UIView *container = self.containerView;
    CGRect bounds = CGRectZero;

    // Container conf
    container.autoresizingMask = 
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin;
    for (UIView *containedView in self.views) {
        bounds = CGRectUnion(bounds, containedView.frame);
        [container addSubview:containedView];
    }

    CGFloat x = [self getContainerXOriging];
    CGFloat y = [self getContainerYOriging];

    x = x == kCenteredOrigin ?
        (self.view.bounds.size.width - bounds.size.width) / 2. : x;
    y = y == kCenteredOrigin ?
        (self.view.bounds.size.height - bounds.size.height) / 2. : y;
    bounds.origin = CGPointMake(x, y);
    [self didCalculateBounds:bounds];

    CGRect forcedBounds = [self getContainerBounds];

    if (CGRectEqualToRect(forcedBounds, CGRectZero)) {
        container.frame = bounds;
    } else {
        container.frame = forcedBounds;
    }

    [self.view addSubview:container];
}

- (void)didCalculateBounds:(CGRect)bounds
{
}

- (id)getBackActionTarget
{
    return self;
}

- (id)getForwardActionTarget
{
    return self;
}

- (SEL)getBackActionSelector
{
    return @selector(popControllerAction);
}

- (SEL)getForwardActionSelector
{
    return NULL;
}


- (UIImageView *)getTitleImageView
{
    return [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:TL_LOGO_FILE_NAME]];
}

- (UIBarButtonItem *)getButtonItemForIcon:(NSString *)icon
                                   target:(id)target
                                 selector:(SEL)selector
{
    UIButton *button = [[UIButton alloc] initWithFrame:TL_BAR_BUTTON_RECT];

    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button addTarget:target action:selector
        forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark -
#pragma mark Actions

- (void)popControllerAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
