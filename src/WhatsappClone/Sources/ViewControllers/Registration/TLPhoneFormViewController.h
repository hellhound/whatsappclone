#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Services/Controllers/Registration/TLPhoneController.h"

#import "TLRegistrationBaseViewController.h"

@interface TLPhoneFormViewController: TLRegistrationBaseViewController
    <UITextFieldDelegate, TLTPhoneControllerDelegate>

@end
