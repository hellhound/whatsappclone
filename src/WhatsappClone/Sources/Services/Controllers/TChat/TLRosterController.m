#import "Application/TLConstants.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "TLRosterController.h"

@interface TLRosterController()

@property (nonatomic, weak) id<TLRosterControllerDelegate> delegate;

- (TLBuddy *)buddyForIndex:(NSInteger)index;

// Notifications
- (void)rosterDidPopulateNotification:(NSNotification *)notification;
@end

@implementation TLRosterController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLRosterDidPopulateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:kTLDidBuddyVCardUpdatedNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

- (id)initWithDelegate:(id<TLRosterControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(rosterDidPopulateNotification:)
            name:kTLRosterDidPopulateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(rosterDidPopulateNotification:)
            name:kTLDidBuddyVCardUpdatedNotification object:nil];
    return self;
}

#pragma mark -
#pragma mark TLRosterController

@synthesize delegate;

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];

    return [[[manager buddyList] allBuddies] count];
}

- (TLBuddy *)buddyForIndex:(NSInteger)index
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];

    return [[[manager buddyList] allBuddies] objectAtIndex:index];
}

- (NSString *)buddyAccountNameForIndex:(NSInteger)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return buddy.accountName;
}

- (NSString *)buddyDisplayNameForIndex:(NSInteger)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return buddy.displayName;
}

#pragma mark -
#pragma mark Notifications

- (void)rosterDidPopulateNotification:(NSNotification *)notification
{
    [self.delegate controllerDidPopulateRoster:self];
}
@end
