#import <Foundation/Foundation.h>

@protocol TLMessageLogStorage;
@class TLMessage;

@interface TLBuddy: NSObject

@property (nonatomic, copy) NSString *displayName; //nickname in xmpp
@property (nonatomic, copy) NSString *accountName; //Jid in xmpp
@property (nonatomic, copy) NSData *photo; //avatar from vcard
@property (nonatomic, weak) TLMessage *lastMessage;
@property (nonatomic, weak) id<TLMessageLogStorage> storage;

+ (TLBuddy *)buddyWithDisplayName:(NSString *)buddyName
                      accountName:(NSString *)accountName;

- (id)initWithDisplayName:(NSString *)buddyName
              accountName:(NSString *)accountName;
- (NSInteger)unreadMessages;
- (void)receiveMessage:(TLMessage *)message;
/*
- (void)sendMessage:(NSString *)message;
*/
@end
