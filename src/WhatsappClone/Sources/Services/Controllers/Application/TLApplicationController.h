#import <Foundation/Foundation.h>

#import "Services/Models/TLAccount.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Managers/AccountManager/TLAccountManager.h"

@interface TLApplicationController: NSObject

@property (nonatomic, weak) id<TLProtocol> manager;
@property (nonatomic, weak) id<TLAccountStorage> accountStorage;
@property (nonatomic, weak) Class accountClass;

+ (void)replaceAccountStorage:(id<TLAccountStorage>)accountStorage;

- (void)connect;
- (void)disconnect;
- (BOOL)shouldPresentRegistrationForm;
@end
