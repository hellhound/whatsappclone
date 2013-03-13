#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Services/Controllers/Registration/TLConfirmController.h"
#import "TLRegistrationBaseViewController.h"

@interface TLConfirmCodeViewController: TLRegistrationBaseViewController
    <UITextFieldDelegate, TLConfirmControllerDelegate>
@end
