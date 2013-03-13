#import "Application/TLConstants.h"
#import "TLTMojiScroller.h"

@interface TLTMojiScroller()

// Outlets
@property (nonatomic, strong) UIScrollView *pageView;
@property (nonatomic, strong) UIPageControl *pageControl;
// Models
@property (nonatomic, weak) id<TLTMojiScrollerDelegate> delegate;
@property (nonatomic, readonly) NSOrderedSet *images;
@property (nonatomic, readonly) NSUInteger currentPage;

+ (NSOrderedSet *)setOfColsAndRowsFromPageSize:(CGSize)pageSize
                                     TMojiSize:(CGSize)TMojiSize;
+ (NSUInteger)numberOfPagesFromImages:(NSOrderedSet *)images
                       pageDimensions:(NSOrderedSet *)dimensions;
+ (CGSize)getContentSizeFromPageSize:(CGSize)pageSize
                           TMojiSize:(CGSize)TMojiSize
                              images:(NSOrderedSet *)images;

// Setup methods
- (void)basicSetupWithDelegate:(id<TLTMojiScrollerDelegate>)delegate;
- (void)pageViewSetup;
- (void)pageControlSetup;
// Everything else
- (void)relayout;
- (void)resetState;
// Actions
- (void)pageControlPageChanged;
@end

@implementation TLTMojiScroller

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayout];
}

#pragma mark -
#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (![scrollView isDragging])
        self.pageControl.currentPage = self.currentPage;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = self.currentPage;
}

#pragma mark -
#pragma mark TLTMojiScroller

// Outlets
@synthesize pageView;
@synthesize pageControl;
// Models
@synthesize delegate;
@synthesize images;

+ (NSOrderedSet *)setOfColsAndRowsFromPageSize:(CGSize)pageSize
                                     TMojiSize:(CGSize)TMojiSize
{
    NSUInteger cols = pageSize.width / TMojiSize.width;
    NSUInteger rows = pageSize.height / TMojiSize.height;

    return [NSOrderedSet orderedSetWithArray:
       @[[NSNumber numberWithUnsignedInteger:cols],
        [NSNumber numberWithUnsignedInteger:rows]]];
}

+ (NSUInteger)numberOfPagesFromImages:(NSOrderedSet *)images
                       pageDimensions:(NSOrderedSet *)dimensions
{
    NSUInteger rows = [dimensions[0] unsignedIntegerValue];
    NSUInteger cols = [dimensions[1] unsignedIntegerValue];
    return [images count] / (rows * cols) + 1;
}

+ (CGSize)getContentSizeFromPageSize:(CGSize)pageSize
                           TMojiSize:(CGSize)TMojiSize
                              images:(NSOrderedSet *)images
{
    NSOrderedSet *dimensions =
        [self setOfColsAndRowsFromPageSize:pageSize TMojiSize:TMojiSize];
    NSUInteger pages =
        [self numberOfPagesFromImages:images pageDimensions:dimensions];
    
    return CGSizeMake(pageSize.width * pages, pageSize.height);
}

- (id)initWithFrame:(CGRect)frame
           delegate:(id<TLTMojiScrollerDelegate>)theDelegate;
{
    if ((self = [super initWithFrame:frame]) != nil) {
        [self basicSetupWithDelegate:theDelegate];
        [self pageViewSetup];
        [self pageControlSetup];
    }
    return self;
}

- (NSOrderedSet *)images
{
    return [self.delegate scrollerWillPresentImages:self];
}

- (NSUInteger)currentPage
{
    CGSize pageSize = self.pageView.bounds.size;
    CGSize TMojiSize = kTLTMojiInputViewTMojiSize;
    NSOrderedSet *dimensions =
        [[self class] setOfColsAndRowsFromPageSize:pageSize
        TMojiSize:TMojiSize];
    NSUInteger pages = [[self class] numberOfPagesFromImages:self.images
        pageDimensions:dimensions];
   return pages * self.pageView.contentOffset.x
       / self.pageView.contentSize.width;
}

- (void)basicSetupWithDelegate:(id<TLTMojiScrollerDelegate>)theDelegate
{
    self.backgroundColor = TL_TMOJI_INPUT_BACKGROUND_TINT;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.delegate = theDelegate;
}

- (void)pageViewSetup
{
    CGRect frame = CGRectZero;
    
    frame.origin = CGPointMake(.0, .0);
    frame.size = kTLTMojiInputViewVPageSize;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];

    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.backgroundColor = TL_TMOJI_INPUT_BACKGROUND_TINT;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // Avoid autoresizing subviews
    scrollView.autoresizesSubviews = NO;
    scrollView.contentMode = UIViewContentModeRedraw;
    scrollView.delegate = self;
    self.pageView = scrollView;
    [self addSubview:pageView];
}

- (void)pageControlSetup
{
    CGSize pageSize = kTLTMojiInputViewVPageSize;
    CGRect frame = CGRectZero;

    frame.origin = CGPointMake(.0, pageSize.height);
    frame.size = kTLTMojiInputViewPageControlSize;

    UIPageControl *thePageControl = [[UIPageControl alloc] initWithFrame:frame];

    thePageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleTopMargin;
    thePageControl.currentPageIndicatorTintColor = TL_MAIN_TINT;
    thePageControl.pageIndicatorTintColor = TL_PAGE_INDICATOR_TINT;
    thePageControl.hidesForSinglePage = YES;
    [thePageControl addTarget:self action:@selector(pageControlPageChanged)
        forControlEvents:UIControlEventValueChanged];
    self.pageControl = thePageControl;
    [self addSubview:pageControl];
}

- (void)updateScroller
{
    // reset scroller state
    [self resetState];
    // tigger the re-layout of this view
    [self setNeedsLayout];
}

- (void)relayout
{
    // pageSize according to current width and height
    CGSize pageSize = [self.pageView bounds].size;
    CGSize TMojiSize = kTLTMojiInputViewTMojiSize;
    NSOrderedSet *pageDimensions =
        [[self class] setOfColsAndRowsFromPageSize:pageSize
        TMojiSize:TMojiSize];

    // Set the number of pages
    self.pageControl.numberOfPages =
        [[self class] numberOfPagesFromImages:self.images
        pageDimensions:pageDimensions];
    // Set the content size
    self.pageView.contentSize =
        [[self class] getContentSizeFromPageSize:pageSize TMojiSize:TMojiSize
        images:self.images];
    // Remove all subviews
    [[self.pageView subviews]
        makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSUInteger cols = [pageDimensions[0] unsignedIntegerValue], colsCount = 0;
    NSUInteger rows = [pageDimensions[1] unsignedIntegerValue], rowsCount = 0;
    CGFloat x = .0, y = .0, offset = .0;

    // Add buttons to the scroller
    for (UIImage *image in self.images) {
        CGRect buttonFrame =
            CGRectMake(x, y, TMojiSize.width, TMojiSize.height);
        UIButton *imageButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [imageButton addTarget:self.delegate
            action:@selector(TMojiButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];

        [imageButton setImage:image forState:UIControlStateNormal];
        [self.pageView addSubview:imageButton];
        colsCount++;
        if (colsCount == cols) {
            colsCount = 0;
            rowsCount++;
        }
        if (rowsCount == rows) {
            rowsCount = 0;
            offset += pageSize.width;
        }
        x = offset + colsCount * TMojiSize.width;
        y = rowsCount * TMojiSize.height;
    }
}

- (void)resetState
{
    // reset the page view
    [self.pageView setContentOffset:CGPointZero animated:NO];
    // reset the page control
    self.pageControl.currentPage = 0;
}

#pragma mark -
#pragma mark Actions

- (void)pageControlPageChanged
{
    CGSize pageSize = self.pageView.bounds.size;
    //CGSize contentSize = self.pageView.contentSize;
    CGFloat x = self.pageControl.currentPage * pageSize.width;
    CGRect region = CGRectMake(x, .0, pageSize.width, pageSize.height);

    [self.pageView scrollRectToVisible:region animated:YES];
}
@end
