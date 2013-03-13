#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLTChatHistoryViewCell: UITableViewCell

@property (nonatomic, strong) NSNumber *unreadMessages;
@property (nonatomic, strong) NSDate *lastDate;

+ (CGFloat)getCellHeight;


@end
