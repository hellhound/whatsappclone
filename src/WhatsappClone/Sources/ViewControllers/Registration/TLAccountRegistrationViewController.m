#import "Application/TLConstants.h"
#import "Categories/UIKit/UIImage+TL568h.h"
#import "TLPhoneFormViewController.h"
#import "TLAccountRegistrationViewController.h"
@interface TLAccountRegistrationViewController ()

// setup methods
- (void)basicSetup;
- (void)backgroundSetup;
- (void)createAccountButtonSetup;
// everything else
- (void)toggleNavigationBar;
// Actions
- (void)createAccountAction;
@end

@implementation TLAccountRegistrationViewController

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self = [super initWithNibName:nibName bundle:bundle]) != nil)
        [self basicSetup];
    return self;
}

- (void)viewDidLoad
{
    [self backgroundSetup];
    [self createAccountButtonSetup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self toggleNavigationBar];
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation
    return NO;
}

#pragma mark -
#pragma mark TLAccountRegistrationViewController

- (void)basicSetup
{
    self.wantsFullScreenLayout = YES;
}

- (void)backgroundSetup
{
    NSString *imageNamed = kTLAccountRegistrationViewBackgroundImage;
    UIImage *background = [UIImage imageNamed568h:imageNamed];
    UIImageView *backgroundView =
        [[UIImageView alloc] initWithImage:background];

    [backgroundView sizeToFit];
    [self.view addSubview:backgroundView];
}

- (void)createAccountButtonSetup
{
    NSString *imageNamed = kTLAccountRegistrationViewButtonImage;
    UIImage *buttonImage = [UIImage imageNamed:imageNamed];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(createAccountAction)
        forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];

    CGFloat y = kTLAccountRegistrationViewButtonOriginY;
    CGRect bounds = self.view.bounds;
    CGRect buttonFrame = button.frame;

    buttonFrame.origin = CGPointMake(
        (bounds.size.width - buttonFrame.size.width) / 2., y);
    button.frame = buttonFrame;
    [self.view addSubview:button];
}

- (void)toggleNavigationBar
{
    BOOL hidden = !self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

#pragma mark -
#pragma mark Actions

- (void)createAccountAction
{
    // Replace the window root view controller
    TLPhoneFormViewController *phoneFormController =
        [[TLPhoneFormViewController alloc] initWithNibName:nil bundle:nil];

    [self presentViewController:[[UINavigationController alloc]
        initWithRootViewController:phoneFormController] animated:YES
        completion:NULL];
}
@end
