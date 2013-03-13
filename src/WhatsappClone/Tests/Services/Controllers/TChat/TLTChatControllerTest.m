#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"

#import "Services/Controllers/TChat/TLTChatController.h"

@interface TLTChatControllerTest: SenTestCase
@end

@implementation TLTChatControllerTest

- (void)testInitWithDelegateShouldReturnATLTChatControler
{
    //setup
    //action
    id chatController = [[TLTChatController alloc] initWithDelegate:nil];
    //verify
    assertThat(chatController, instanceOf([TLTChatController class]));
}

@end
