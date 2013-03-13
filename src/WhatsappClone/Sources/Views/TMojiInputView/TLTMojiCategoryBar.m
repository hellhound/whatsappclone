#import "Application/TLConstants.h"
#import "Categories/UIKit/UIImage+TLAdditions.h"
#import "TLTMojiCategoryBar.h"

@interface TLTMojiCategoryBar()

// Models
@property (nonatomic, weak) id<TLTMojiCategoryBarDelegate> categoryDelegate;
@property (nonatomic, weak) UIButton *pressedButton;
@property (nonatomic, readonly) NSOrderedSet *images;

+ (CGSize)getContentSizeFromButtonSize:(CGSize)buttonSize
                                images:(NSOrderedSet *)images;
+ (UIImage *)getDefaultButtonBackgroundImageForButtonSize:(CGSize)buttonSize;
+ (UIImage *)getPressedButtonBackgroundImageForButtonSize:(CGSize)buttonSize;
+ (UIButton *)              getButton:(UIButton *)button
   forDefaultStateWithBackgroundImage:(UIImage *)image;
+ (UIButton *)              getButton:(UIButton *)button
   forPressedStateWithBackgroundImage:(UIImage *)image;
+ (UIButton *)getButtonUsingSize:(CGSize)size
                           image:(UIImage *)image
                          target:(id)target
                          origin:(CGPoint)origin;

// Setup methods
- (void)basicSetupWithDelegate:(id<TLTMojiCategoryBarDelegate>)delegate;
// Everything else
- (void)relayout;
- (void)hightlightFirstButtonIfNeeded:(NSArray *)buttons;
- (void)cleanButton:(UIButton *)button;
- (void)hightlightButton:(UIButton *)button;
- (void)cleanButtonStatesAndHighlightPressedButton:(UIButton *)pressedButton;
// Actions
- (void)buttonPressedAction:(UIButton *)pressedButton;
@end

@implementation TLTMojiCategoryBar

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark -
#pragma mark TLTMojiCategoryBar

@synthesize categoryDelegate;
@synthesize pressedButton;

+ (CGSize)getContentSizeFromButtonSize:(CGSize)buttonSize
                                images:(NSOrderedSet *)images
{
    return CGSizeMake(buttonSize.width * [images count], buttonSize.height);
}

+ (UIImage *)getDefaultButtonBackgroundImageForButtonSize:(CGSize)size
{
    return [UIImage imageWithColor:TL_TMOJI_CATEGORY_DEFAULT_BUTTON_TINT
        size:size];
}

+ (UIImage *)getPressedButtonBackgroundImageForButtonSize:(CGSize)size
{
    return [UIImage imageWithColor:TL_TMOJI_CATEGORY_PRESSED_BUTTON_TINT
        size:size];
}

+ (UIButton *)              getButton:(UIButton *)button
   forDefaultStateWithBackgroundImage:(UIImage *)image
{
    [button setBackgroundImage:image forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)              getButton:(UIButton *)button
   forPressedStateWithBackgroundImage:(UIImage *)image
{
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
    return button;
}


+ (UIButton *)getButtonUsingSize:(CGSize)size
                           image:(UIImage *)image
                          target:(id)target
                          origin:(CGPoint)origin
{
    CGRect frame = CGRectZero;

    frame.origin = origin;
    frame.size = size;

    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    UIImage *defaultColor =
        [self getDefaultButtonBackgroundImageForButtonSize:size];
    UIImage *pressedColor =
        [self getPressedButtonBackgroundImageForButtonSize:size];

    [button setImage:image forState:UIControlStateNormal];
    button =
        [self getButton:button forDefaultStateWithBackgroundImage:defaultColor];
    button =
        [self getButton:button forPressedStateWithBackgroundImage:pressedColor];
    [button addTarget:target action:@selector(buttonPressedAction:)
         forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (id)initWithFrame:(CGRect)frame
           delegate:(id<TLTMojiCategoryBarDelegate>)theDelegate
{
    if ((self = [super initWithFrame:frame]) != nil) {
        [self basicSetupWithDelegate:theDelegate];
        [self relayout];
    }
    return self;
}

- (NSOrderedSet *)images
{
    return [self.categoryDelegate categoryBarWillPresentCategories:self];
}

- (void)basicSetupWithDelegate:(id<TLTMojiCategoryBarDelegate>)theDelegate
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleTopMargin;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceHorizontal = YES;
    // Avoid autoresizing subviews
    self.autoresizesSubviews = NO;
    self.backgroundColor = TL_TMOJI_CATEGORY_BAR_BACKGROUND_TINT;
    self.categoryDelegate = theDelegate;
}

- (void)relayout
{
    CGSize buttonSize = kTLTMojiInputViewCategoryButtonSize;

    // Set the content size
    self.contentSize = [[self class] getContentSizeFromButtonSize:buttonSize
        images:self.images];
    // Remove all subviews
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat x = .0;

    NSMutableArray *buttons = [NSMutableArray array];

    for (UIImage *image in self.images) {
        CGPoint origin = CGPointMake(x, .0);
        UIButton *button = [[self class] getButtonUsingSize:buttonSize
            image:image target:self origin:origin];

        [buttons addObject:button];
        [self addSubview:button];
        x += buttonSize.width + 1;
    }
    [self hightlightFirstButtonIfNeeded:buttons];
}

- (void)hightlightFirstButtonIfNeeded:(NSArray *)buttons
{
    if ([buttons count] > 0) {
        UIButton *button = buttons[0];

        if (self.pressedButton == nil) {
            [self hightlightButton:button];
            self.pressedButton = button;
        }
    }
}

- (void)cleanButton:(UIButton *)button
{
    CGSize buttonSize = kTLTMojiInputViewCategoryButtonSize;

    [[self class] getButton:button
        forDefaultStateWithBackgroundImage:[[self class]
        getDefaultButtonBackgroundImageForButtonSize:buttonSize]];
}

- (void)hightlightButton:(UIButton *)button
{
    CGSize buttonSize = kTLTMojiInputViewCategoryButtonSize;

    [[self class] getButton:button
        forDefaultStateWithBackgroundImage:[[self class]
        getPressedButtonBackgroundImageForButtonSize:buttonSize]];
}

- (void)cleanButtonStatesAndHighlightPressedButton:(UIButton *)thePressedButton
{
    if (self.pressedButton != nil)
        [self cleanButton:self.pressedButton];
    self.pressedButton = thePressedButton;
    [self hightlightButton:thePressedButton];
}

#pragma mark -
#pragma mark Actions

- (void)buttonPressedAction:(UIButton *)thePressedButton
{
    [self cleanButtonStatesAndHighlightPressedButton:thePressedButton];
    [categoryDelegate category:self wasTappedWithImage:
        [thePressedButton imageForState:UIControlStateNormal]];
}
@end
