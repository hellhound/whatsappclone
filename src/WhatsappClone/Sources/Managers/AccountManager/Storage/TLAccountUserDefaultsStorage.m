#import "TLAccountUserDefaultsStorage.h"

static NSString *const kStorageKey = @"TLAccountSingletonStorage";
static NSString *const kPhoneKey = @"phone";
static NSString *const kPasswordKey = @"password";
static NSString *const kFirstNameKey = @"firstName";
static NSString *const kLastNameKey = @"lastName";
static NSString *const kPhotoKey = @"photo";

@interface TLAccountUserDefaultsStorage()

- (TLAccount *)loadFromStorage;
- (void)saveToStorage:(TLAccount *)account;
@end

@implementation TLAccountUserDefaultsStorage

#pragma mark -
#pragma mark <TLAccountStorage>

- (TLAccount *)getAccount
{
    return [self loadFromStorage];
}

- (void)saveAccount:(TLAccount *)account
{
    return [self saveToStorage:account];
}

- (void)clearStorage
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStorageKey];
}

#pragma mark -
#pragma mark TLAccountUserDefaultsStorage

- (TLAccount *)loadFromStorage
{
    NSDictionary *storedAccount =
        [[NSUserDefaults standardUserDefaults] dictionaryForKey:kStorageKey];

    if (storedAccount == nil)
        return nil;

    NSString *phone = storedAccount[kPhoneKey];
    NSString *password = storedAccount[kPasswordKey];
    NSString *firstName = storedAccount[kFirstNameKey];
    NSString *lastName = storedAccount[kLastNameKey];
    NSData *photo = storedAccount[kPhotoKey];

    TLAccount *account = [TLAccount sharedInstance];

    account.phone = phone;
    account.password = password;
    account.firstName = firstName;
    account.lastName = lastName;
    account.photo = photo;

    return account;
}

- (void)saveToStorage:(TLAccount *)account
{
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setValue:account.phone forKey:kPhoneKey];
    if (account.password != nil) {
        [entry setValue:account.password forKey:kPasswordKey];
    }
    if (account.firstName != nil) {
        [entry setValue:account.firstName forKey:kFirstNameKey];
    }
    if (account.lastName != nil) {
        [entry setValue:account.lastName forKey:kLastNameKey];
    }
    if (account.photo != nil) {
        [entry setValue:account.photo forKey:kPhotoKey];
    }
    [[NSUserDefaults standardUserDefaults] setObject:entry forKey:kStorageKey];
}
@end
