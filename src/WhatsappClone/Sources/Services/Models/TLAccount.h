#import <Foundation/Foundation.h>
#import "Managers/Networking/API/TLAPIManager.h"

@interface TLAccount: NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSData *photo;

+ (TLAccount *)sharedInstance;
+ (BOOL)verifyPhoneNumber:(NSString *)phone;
+ (void)replaceInstance:(TLAccount *)instance;
- (NSString *)getUUID;
@end
