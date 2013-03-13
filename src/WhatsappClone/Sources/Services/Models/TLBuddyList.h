#import <Foundation/Foundation.h>

#import "TLBuddy.h"

@interface TLBuddyList: NSObject

@property (nonatomic, strong) NSMutableArray *allBuddies;

- (void)addBuddy:(TLBuddy *)buddy;
- (TLBuddy *)buddyForAccountName:(NSString *)accountName;
@end
