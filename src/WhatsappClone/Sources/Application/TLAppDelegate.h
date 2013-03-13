#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLAppDelegate: NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)configureStyles;
- (void)didCompleteRegistrationProcess;

@end
