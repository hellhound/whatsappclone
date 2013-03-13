//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"

@interface UIBubbleHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;

@end

@implementation UIBubbleHeaderTableViewCell

@synthesize label = _label;
@synthesize date = _date;

+ (CGFloat)height
{
    return 28.0;
}

- (void)setDate:(NSDate *)value
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    NSString *text = [dateFormatter stringFromDate:value];
    [dateFormatter release];
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    //background image
    UIImage *imageBackgound = [UIImage imageNamed:@"tchatHeaderBackground"];
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(.0, 117., .0, 117.);
    //TODO: setting the insets

    UIImageView *headerBackground = [[[UIImageView alloc] 
        initWithFrame:CGRectMake(.0, 6., 320., 17.)] autorelease];
    headerBackground.image = 
        [imageBackgound resizableImageWithCapInsets:imageInsets];
    headerBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    

    [self addSubview:headerBackground];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 
            self.frame.size.width, [UIBubbleHeaderTableViewCell height])] autorelease];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.shadowOffset = CGSizeMake(0, 1);
    //self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}



@end
