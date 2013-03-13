#import "TLConstants.h"
#import "Services/Models/TLAccount.h"
#import "TLApplicationController.h"

static __strong id<TLAccountStorage> kAccountStorage = nil;

// TODO remove after demo!
@interface TLApplicationController ()

// TODO remove after demo!
- (BOOL)shouldShorcutTheRegistration;
@end

@implementation TLApplicationController

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil)
        [self.accountStorage getAccount];
    return self;
}

#pragma mark -
#pragma mark TLApplicationController

@synthesize manager;
@synthesize accountStorage;
@synthesize accountClass;

+ (void)replaceAccountStorage:(id<TLAccountStorage>)accountStorage
{
    kAccountStorage = accountStorage;
}

- (id<TLProtocol>)manager
{
    if (manager == nil)
        manager = [[TLProtocolManager sharedInstance] protocol];
    return manager;
}

- (id<TLAccountStorage>)accountStorage
{
    if (kAccountStorage != nil) {
        accountStorage = kAccountStorage;
    } else if (accountStorage == nil) {
        accountStorage = [[TLAccountManager sharedInstance] storage];
    }
    return accountStorage;
}

- (Class)accountClass
{
    if (accountClass == nil)
        accountClass = [TLAccount class];
    return accountClass;
}

- (void)connect
{
    TLAccount *account = [self.accountClass sharedInstance];

    // TODO remove after demo!
    if ([self shouldShorcutTheRegistration]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:kTLUsernamePreference];
        NSString *password = [defaults stringForKey:kTLPasswordPreference];

        if (account == nil)
            account = [self.accountClass sharedInstance];
        account.username = username;
        account.password = password;
    }
    self.manager.account = account;
    [self.manager connectWithPassword:account.password];
}

- (void)disconnect
{
    [self.manager disconnect];
}

- (BOOL)shouldPresentRegistrationForm
{
    // TODO remove after demo!
    if ([self shouldShorcutTheRegistration])
        return NO;

    TLAccount *account = [self.accountClass sharedInstance];

    return account.phone == nil ||  account.password ==nil ||
        [account.phone isEqualToString:@""] ||
        [account.password isEqualToString:@""];
}

// TODO remove after demo!
- (BOOL)shouldShorcutTheRegistration
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:kTLUsernamePreference];
    NSString *password = [defaults stringForKey:kTLPasswordPreference];

    if (username == nil || password == nil ||
            [username isEqualToString:@""] || [password isEqualToString:@""])
        return NO;
    return YES;
}
@end
