#import <Foundation/Foundation.h>

#import "Application/TLConstants.h"
#import "TLMediaData.h"
#import "TLBuddy.h"

@protocol TLProtocol;

@interface TLMessage: NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TLMediaData *mediaData;
@property (nonatomic, strong) TLBuddy *buddy;
@property (nonatomic, assign) BOOL received;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, strong) NSDate *date;

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy message:(NSString *)message;
+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                        message:(NSString *)message
                       received:(BOOL)received;

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                        message:(NSString *)message
                       received:(BOOL)received
                         unread:(BOOL)unread;

+ (TLMessage *)messageWithBuddy:(TLBuddy *)buddy
                      mediaData:(TLMediaData *)mediaData
                       received:(BOOL)received
                         unread:(BOOL)unread;

- (id)initWithBuddy:(TLBuddy *)buddy message:(NSString *)message;
- (id)initWithBuddy:(TLBuddy *)buddy
            message:(NSString *)message
           received:(BOOL)received
             unread:(BOOL)unread;
- (BOOL)isATmojiMessage;
- (BOOL)isAMediaMessage;
- (NSString *)mediaDescription;
- (void)send;
//just for tests
- (id)initWithProtocol:(id<TLProtocol>)protocol;
@end
