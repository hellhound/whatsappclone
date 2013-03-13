#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "Application/TLConstants.h"
#import "Services/Models/TLBuddyList.h"

@interface TLBuddyListTest: SenTestCase
@end

@implementation TLBuddyListTest

static NSString *const kTestString = @"aString";

//dummy objects
- (TLBuddy *)createDummyBuddy
{
    return [[TLBuddy alloc] init];
}

//allBuddies property
- (void)testAllBuddiesShouldReturnANSMutableArray
{
    // setup
    TLBuddyList *buddyList = [[TLBuddyList alloc] init];

    // action
    buddyList.allBuddies = [NSMutableArray array];
    
    // assert
    assertThat(buddyList.allBuddies, instanceOf([NSMutableArray class]));
}

- (void)testAddBuddyShouldIncrementTheAllBudiesList
{
    // setup
    TLBuddyList *buddyList = [[TLBuddyList alloc] init];
    TLBuddy *buddy = [self createDummyBuddy];

    // action
    [buddyList addBuddy:buddy];
    NSMutableArray *allBuddies = buddyList.allBuddies;
    
    // assert
    assertThat(allBuddies, contains(buddy, nil));
}

- (void)testBuddyForAccountNameShouldReturnATLBuddy
{
    // setup
    TLBuddyList *buddyList = [[TLBuddyList alloc] init];
    TLBuddy *buddy = [self createDummyBuddy];
    buddy.accountName = kTestString;

    // action
    [buddyList addBuddy:buddy];
    TLBuddy *newBuddy = [buddyList buddyForAccountName:kTestString];
    
    // assert
    assertThat(buddy, equalTo(newBuddy));
}
@end
