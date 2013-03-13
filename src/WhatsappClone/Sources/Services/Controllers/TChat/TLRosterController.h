#import <Foundation/Foundation.h>

#import "TLBaseController.h"

@protocol TLRosterControllerDelegate;

@interface TLRosterController: TLBaseController

- (id)initWithDelegate:(id<TLRosterControllerDelegate>)theDelegate;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)buddyAccountNameForIndex:(NSInteger)index;
- (NSString *)buddyDisplayNameForIndex:(NSInteger)index;
@end

@protocol TLRosterControllerDelegate <TLBaseControllerDelegate>

- (void)controllerDidPopulateRoster:(TLRosterController *)controller;
@end
