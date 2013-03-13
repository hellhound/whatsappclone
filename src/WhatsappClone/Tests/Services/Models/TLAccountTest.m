#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"
#import "TLTestConstants.h"
#import "Services/Models/TLAccount.h"

@interface TLAccountTest: SenTestCase

- (TLAccount *)getAccount;
@end

@implementation TLAccountTest

static NSString *const kTestString = @"aString";
static BOOL const kTestBool = YES;
static NSString *const kAPhone = @"3107654321"; // California-area code
static NSString *const kAPassword = @"554321"; // Verification code
static NSString *const kAUsername = @"username"; // Verification code
static NSString *const kAUUID = @"username@" kTLHostDomain;

- (TLAccount *)getAccount
{
    TLAccount *account = [TLAccount sharedInstance];

    account.phone = kAPhone;
    return account;
}

- (void)setUp
{
    [TLAccount replaceInstance:nil];
}

- (void)testUsernameShouldReturnANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.username = kTestString;
    
    // assert
    assertThat(account.username, instanceOf([NSString class]));
}

- (void)testUsernameShouldSetANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.username = kTestString;
    
    // assert
    assertThat(account.username, equalTo(kTestString));
}

- (void)testAccountWithUserNameShouldReturnTLAccount
{
    // setup
    TLAccount *account = [self getAccount];

    account.username = kTestString;

    // action
    NSString *username = account.username;
    
    // assert
    assertThat(username, equalTo(kTestString));
}

- (void)testPhoneNumberShouldReturnANSString
{
    // setup
    TLAccount *account = [self getAccount];

    account.phone = kTestString;

    // action
    NSString *phone = account.phone;

    // asert
    assertThat(phone, equalTo(kTestString));
}

- (void)testPhoneNumberShouldsetANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.phone = kTestString;

    // asert
    assertThat(account.phone, equalTo(kTestString));
}

- (void)testPasswordShouldReturnANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.password = kAPassword;
    
    // assert
    assertThat(account.password, instanceOf([NSString class]));
}

- (void)testPasswordShouldSetANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.password = kAPassword;
    
    // assert
    assertThat(account.password, equalTo(kAPassword));
}

- (void)testFirstNameShouldReturnANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.firstName = kTestString;
    
    // assert
    assertThat(account.firstName, instanceOf([NSString class]));
}

- (void)testFirstNameShouldSetANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.firstName = kTestString;
    
    // assert
    assertThat(account.firstName, equalTo(kTestString));
}

- (void)testLastNameShouldReturnANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.lastName = kTestString;
    
    // assert
    assertThat(account.lastName, instanceOf([NSString class]));
}

- (void)testLastNameShouldSetANSString
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.lastName = kTestString;
    
    // assert
    assertThat(account.lastName, equalTo(kTestString));
}

- (void)testGetUUIDShouldReturnASTringWithHost
{
    // setup
    TLAccount *account = [self getAccount];

    // action
    account.username = kAUsername;
    
    // assert
    assertThat([account getUUID], equalTo(kAUUID));
}

- (void)testSharedInstanceShouldReturnATLAccount
{
    // setup
    TLAccount *account = [self getAccount];

    [TLAccount replaceInstance:account];

    // action
    account = [TLAccount sharedInstance];

    // asert
    assertThat(account, instanceOf([TLAccount class]));
}

- (void)testSharedInstanceShouldReturnATLAccountSingleton
{
    // setup
    TLAccount *account = [self getAccount];
    TLAccount *returned = nil;

    [TLAccount replaceInstance:account];

    // action
    returned = [TLAccount sharedInstance];

    // asert
    assertThat(returned, notNilValue());
    assertThat(returned, equalTo(account));
}

- (void)testSharedInstanceShouldReturnSameAsCopy
{
    // setup
    TLAccount *account = nil;

    [TLAccount replaceInstance:[self getAccount]];

    // action
    account = [TLAccount sharedInstance];

    // asert
    assertThat(account, notNilValue());
    assertThat(account, equalTo([account copy]));
}

// verifyPhoneNumber method
- (void)testVerifyPhoneNumberShouldReturnYESWithValidPhoneNumber
{
    // setup
    NSString *aPhone = kAPhone;

    // action
    BOOL isAValidPhoneNumber = [TLAccount verifyPhoneNumber:aPhone];
    
    // assert
    assertThat([NSNumber numberWithBool:isAValidPhoneNumber],
        equalTo(NUMBER_YES));
}

- (void)testVerifyPhoneNumberShouldReturnNOWithNilPhoneNumber
{
    // setup
    NSString *nilValue = nil;

    // action
    BOOL isAValidPhoneNumber = [TLAccount verifyPhoneNumber:nilValue];
    
    // assert
    assertThat([NSNumber numberWithBool:isAValidPhoneNumber],
        equalTo(NUMBER_NO));
}
- (void)testVerifyPhoneNumberShouldReturnNOWithInvalidPhoneNumber
{
    // setup
    NSString *invalidPhone = @"310234";

    // action
    BOOL isAValidPhoneNumber = [TLAccount verifyPhoneNumber:invalidPhone];
    
    // assert
    assertThat([NSNumber numberWithBool:isAValidPhoneNumber],
        equalTo(NUMBER_NO));
}
@end
