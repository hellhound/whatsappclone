#import <Foundation/Foundation.h>

#import "Managers/Networking/API/TLAPIManager.h"
#import "../TLBaseController.h"

@protocol TLConfirmControllerDelegate;

@interface TLConfirmController: TLBaseController

- (id)initWithEndpoint:(id<TLAPIRegistrationClient>)endpoint;

- (BOOL)isConfirmationCodeValid:(NSString *)string;
- (void)sendVerificationCode:(NSString *)code;
@end

@protocol TLConfirmControllerDelegate <TLBaseControllerDelegate>

- (void)didSuccessVerificationSaved;
- (void)didFailedVerificationSavedWithErrorMessage:(NSString *)errorMsg;
@end
