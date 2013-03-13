#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Services/Controllers/Registration/TLAccountDataController.h"
#import "TLRegistrationBaseViewController.h"

@interface TLAccountDataFormViewController: TLRegistrationBaseViewController
    <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate, TLAccountDataControllerDelegate>
@end
