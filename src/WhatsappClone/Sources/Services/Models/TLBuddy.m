#import "Application/TLConstants.h"
#import "NSString+HTML.h"
#import "Managers/MessageLog/TLMessageLogManager.h"
#import "TLMessage.h"
#import "TLBuddy.h"

@implementation TLBuddy

#pragma mark -
#pragma mark TLBuddy

@synthesize displayName, lastMessage, storage, photo;

+ (TLBuddy *)buddyWithDisplayName:(NSString *)theDisplayName
                      accountName:(NSString *)theAccountName
{
    return [[self alloc] initWithDisplayName:theDisplayName
        accountName:theAccountName];
}

- (id)initWithDisplayName:(NSString *)theDisplayName
              accountName:(NSString *)theAccountName
{
    if ((self = [super init]) != nil) {
        self.displayName = theDisplayName;
        self.accountName = theAccountName;
    }
    return self;
}

- (id<TLMessageLogStorage>)storage;
{
    if (storage == nil){
        storage = [[TLMessageLogManager sharedInstance] storage];
    }
    return storage;
}

- (NSInteger)unreadMessages
{
    return [self.storage countUnreadMessagesForBuddy:self];
}

- (void)receiveMessage:(TLMessage *)message
{
    if (message != nil) {
        // TODO We should strip HTML entities from the messages
        /*
        NSString *rawMessage = [[[[message.message stringByStrippingHTML]
            stringByConvertingHTMLToPlainText] stringByEncodingHTMLEntities]
            stringByLinkifyingURLs];
        */
        self.lastMessage = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:
            kTLMessageProcessedNotification object:self];
    }
}
@end
