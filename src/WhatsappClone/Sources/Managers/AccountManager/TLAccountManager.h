#import <Foundation/Foundation.h>

#import "Services/Models/TLAccount.h"

@protocol TLAccountStorage;

@interface TLAccountManager: NSObject

@property (nonatomic, readonly) id<TLAccountStorage> storage;

+ (TLAccountManager *)sharedInstance;
+ (void)replaceInstance:(TLAccountManager *)instance;
+ (id<TLAccountStorage>)storage;
+ (void)setStorage:(id<TLAccountStorage>)storage;
@end

@protocol TLAccountStorage <NSObject>

- (TLAccount *)getAccount;
- (void)saveAccount:(TLAccount *)account;
- (void)clearStorage;
@end
