#import "TLTChatHistoryViewCell.h"

@implementation TLTChatHistoryViewCell

#pragma mark -
#pragma mark TLTChatHistoryViewCell

@synthesize unreadMessages, lastDate;

+ (CGFloat)getCellHeight
{
    return 60.;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        CGRect accesoryRect = CGRectMake(.0, .0, 50., 40.);
        UIView *accessoryView = [[UIView alloc] initWithFrame:accesoryRect];
        //text properties
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        //accessoryView properties
        self.accessoryView = accessoryView;
    }
    return self;
}

- (void)prepareForReuse
{
    for (UIView *subview in [self.accessoryView subviews]) {
        [subview removeFromSuperview];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(5., 5., 48., 48.);

    CGRect tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = 58;
    tmpFrame.origin.y = 5;
    self.textLabel.frame = tmpFrame;

    tmpFrame = self.detailTextLabel.frame;
    tmpFrame.origin.x = 58;
    self.detailTextLabel.frame = tmpFrame;

    //accessoryview settings
    //date text

    if(self.lastDate != nil){
        UILabel *dateLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(.0, .0, 50., 10.)];
        dateLabel.font = [UIFont systemFontOfSize:10];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        //[dateFormatter setDateFormat:@"MMM d"];
        dateLabel.text = [dateFormatter stringFromDate:self.lastDate];
        if (!([dateLabel.text isEqualToString:@"Today"] || [dateLabel.text isEqualToString:@"Yesterday"]))
        {
            [dateFormatter setDoesRelativeDateFormatting:NO];
            [dateFormatter setDateFormat:@"MMM d"];
            dateLabel.text = [dateFormatter stringFromDate:self.lastDate];
            
        }
        [self.accessoryView addSubview:dateLabel];
    }


    //unread text
    if(self.unreadMessages != nil && [self.unreadMessages intValue] > 0){
        UIImageView *unreadBadge = [[UIImageView alloc] 
            initWithFrame:CGRectMake(14., 18., 20., 19.)];
        unreadBadge.image = [UIImage imageNamed:@"unread"];
        [self.accessoryView addSubview:unreadBadge];

        UILabel *unreadLabel = [[UILabel alloc] 
            initWithFrame:CGRectMake(.0, 18., 50., 15.)];
        unreadLabel.font = [UIFont systemFontOfSize:13];
        unreadLabel.textAlignment = NSTextAlignmentCenter;
        unreadLabel.backgroundColor = [UIColor clearColor];
        unreadLabel.textColor = [UIColor whiteColor];
        unreadLabel.text = [self.unreadMessages stringValue];
        [self.accessoryView addSubview:unreadLabel];
    }
}
@end
