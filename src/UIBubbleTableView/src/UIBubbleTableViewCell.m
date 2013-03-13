//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;
//added
@property (nonatomic, retain) UILabel *nickLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize mainController = _mainController;
@synthesize avatarImage = _avatarImage;
//added
@synthesize nickLabel = _nickLabel;
@synthesize dateLabel = _dateLabel;

- (id)init
{
    if ((self = [super init]) != nil) {
        self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [self.dateFormatter setDateFormat:@"h:mm a"];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    self.dateFormatter = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    NSString *dateStr = [self.dateFormatter stringFromDate:self.data.date];
    UIFont *dateFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    CGSize dateSize = [dateStr sizeWithFont:dateFont constrainedToSize:CGSizeMake(60, 9999) lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    //CGFloat y = .0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar && type == BubbleTypeSomeoneElse)
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
#endif
        
        self.avatarImage.contentMode = UIViewContentModeScaleAspectFit;
        self.avatarImage.layer.masksToBounds = YES;
        [self.avatarImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.avatarImage.layer setBorderWidth: 2.0];

        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 8 : self.frame.size.width - 58;
        //CGFloat avatarY = self.frame.size.height - 50;
        CGFloat avatarY = 20;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 37, 37);
        [self addSubview:self.avatarImage];
        
        //CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        //if (delta > 0) y = delta - 20.;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }
    /*
    CGFloat dateX;
    if (type == BubbleTypeSomeoneElse) {
        dateX = x + width + self.data.insets.left + self.data.insets.right;
    } else if (type == BubbleTypeMine) {
        dateX = x - dateSize.width - 4;
    }
    */
    
    

    //added nickname support
    //TODO uncomment when enabling group chats
//    if(self.data.nickname && type == BubbleTypeSomeoneElse){
//        [self.nickLabel removeFromSuperview];
//        CGFloat labelWidth = self.frame.size.width - 54;
//        CGFloat labelx = (type == BubbleTypeSomeoneElse) ? 60 : -8;
//        CGFloat labely = 20;
//        self.nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelx, labely, labelWidth, 20)];
//        self.nickLabel.textAlignment = (type == BubbleTypeSomeoneElse) ? UITextAlignmentLeft : UITextAlignmentRight;
//        self.nickLabel.textColor = [UIColor lightGrayColor];
//        self.nickLabel.backgroundColor = [UIColor clearColor];
//        self.nickLabel.text = self.data.nickname;
//        self.nickLabel.font = dateFont;
//        [self addSubview:self.nickLabel];
//
//    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, 20. + self.data.insets.top, width, height);
    
    //self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];
    
    [self.dateLabel removeFromSuperview];
    self.dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - dateSize.width)/2.0, self.data.insets.top - 5, dateSize.width, dateSize.height)] autorelease];
    self.dateLabel.numberOfLines = 1;
    self.dateLabel.text = dateStr;
    self.dateLabel.font = dateFont;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.dateLabel];

    if (self.data.withBubble) {

        if (type == BubbleTypeSomeoneElse)
        {
            self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

        }
        else {
            self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        }

        //self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
        self.bubbleImage.frame = CGRectMake(x, 20., width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    }
}
@end
