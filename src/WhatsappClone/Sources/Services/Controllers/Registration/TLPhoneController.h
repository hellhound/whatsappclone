#import <Foundation/Foundation.h>

#import "Services/Controllers/TLBaseController.h"
#import "Services/Models/TLAccount.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Managers/AccountManager/TLAccountManager.h"

@protocol TLTPhoneControllerDelegate;

@interface TLPhoneController: TLBaseController

- (BOOL)verifyPhoneStringAndSend:(NSString *)phoneStr;
- (void)sendPhoneNumber:(NSString *)phoneStr;
@end

@protocol TLTPhoneControllerDelegate <TLBaseControllerDelegate>

- (void)phoneDidSendFailedPhoneWithMessage:(NSString *)errorMessage;
- (void)phoneDidSendSuccessPhone;
@end
