#import <Foundation/Foundation.h>

#import "Services/Models/TLMessage.h"
#import "Services/Models/TLBuddy.h"

@protocol TLMessageLogStorage <NSObject>

- (NSArray *)messages;
- (NSArray *)messagesForBuddy:(TLBuddy *)buddy;
- (NSArray *)messagesForBuddy:(TLBuddy *)buddy
               sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)messagesForBuddyAccountName:(NSString *)accountName
               sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)messagesWithSortDescriptors:(NSArray *)sortDescriptors;
- (NSInteger)countUnreadMessagesForBuddy:(TLBuddy *)buddy;
- (NSArray *)buddiesByMessagesWithSortDescriptors:(NSArray *)sortDescriptors;
- (void)setUnreadMessagesAsReadForBuddyAcountName:(NSString *)accountName;
- (void)addMessage:(TLMessage *)message;
- (void)reloadStorage;
- (void)setFixture:(NSArray *)fixture;
@end

@interface TLMessageLogManager: NSObject

@property (nonatomic, readonly) id<TLMessageLogStorage> storage;

+ (TLMessageLogManager *)sharedInstance;
@end
