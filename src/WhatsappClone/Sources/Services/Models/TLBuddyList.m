#import "TLBuddyList.h"

@implementation TLBuddyList

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil)
        self.allBuddies = [[NSMutableArray alloc] init];
    return self;
}

#pragma mark -
#pragma mark TLBuddyList

@synthesize allBuddies;

- (void)addBuddy:(TLBuddy *)buddy
{
    [self.allBuddies addObject:buddy];
}

- (TLBuddy *)buddyForAccountName:(NSString *)accountName
{
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"accountName == %@", accountName];
    NSArray *matchingBuddies =
        [self.allBuddies filteredArrayUsingPredicate:predicate];
    return [matchingBuddies lastObject];
}
@end
