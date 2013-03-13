#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"

#import "Views/TLHitForwardingView.h"
#import "Services/Controllers/TChat/TLTChatController.h"
#import "Views/TMojiInputView/TLTMojiInputView.h"
#import "Views/TLMediaInputView.h"

@interface TLTChatViewController: UITableViewController <UITextFieldDelegate,
    UIBubbleTableViewDataSource, TLTChatControllerDelegate,
    TLHitForwardingViewDelegate, TLTMojiInputViewDelegate, TLMediaInputViewDelegate>

- (id)initWithBuddyAccountName:(NSString *)theAccountName
                   displayName:(NSString *)theDisplayName
                         photo:(NSData *)thePhoto;
- (void)scrollToTheEnd;
@end
