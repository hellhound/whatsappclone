#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLConstants.h"
#import "ViewControllers/TChat/TLTChatHistoryViewController.h"
#import "ViewControllers/Registration/TLAccountRegistrationViewController.h"
#import "Services/Controllers/Application/TLApplicationController.h"
#import "Services/Models/TLAccount.h"
#import "TLAppDelegate.h"

@interface TLAppDelegate ()

@property (nonatomic, strong) TLApplicationController *service;
@end

@implementation TLAppDelegate

#pragma mark -
#pragma mark <UIApplicationDelegate>

- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:
        [[UIScreen mainScreen] bounds]];

    UIViewController *rootViewController;

    if ([self.service shouldPresentRegistrationForm]) {
        rootViewController = [[TLAccountRegistrationViewController alloc]
            initWithNibName:nil bundle:nil];
    } else {
        rootViewController = [[UINavigationController alloc]
            initWithRootViewController:[[TLTChatHistoryViewController alloc]
            initWithStyle:UITableViewStylePlain]];
    }
    self.window.rootViewController = rootViewController;
    //calling the styles methos
    [self configureStyles];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.service connect];
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
    [self.service disconnect];
}

#pragma mark -
#pragma mark TLAppDelegate

@synthesize service;

- (TLApplicationController *)service
{
    if (service == nil)
        service = [[TLApplicationController alloc] init];
    return service;
}

- (void)configureStyles
{
    [[UINavigationBar appearance] setTintColor:TL_MAIN_TINT];
    [[UIToolbar appearance] setTintColor:TL_MAIN_TINT];
}

- (void)didCompleteRegistrationProcess
{
    self.window.rootViewController = [[UINavigationController alloc]
        initWithRootViewController:[[TLTChatHistoryViewController alloc]
        initWithStyle:UITableViewStylePlain]];
}
@end
