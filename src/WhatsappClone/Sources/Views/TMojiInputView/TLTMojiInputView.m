#import "Application/TLConstants.h"
#import "TLTMojiCatalogDTO.h"
#import "TLTMojiScroller.h"
#import "TLTMojiCategoryBar.h"
#import "TLTMojiInputView.h"

@interface TLTMojiInputView()

// Outlets
@property (nonatomic, strong) TLTMojiScroller *scroller;
@property (nonatomic, strong) TLTMojiCategoryBar *categoryBar;
// Models
@property (nonatomic, weak) id<TLTMojiInputViewDelegate> delegate;
@property (nonatomic, copy) NSOrderedSet *catalogDTOs;
@property (nonatomic, weak) TLTMojiCatalogDTO *selectedCatalogDTO;

// Setup methods
- (void)basicSetupWithCatalogDTOs:(NSOrderedSet *)catalogDTOs;
- (void)scrollerSetup;
- (void)categoryBarSetup;
@end

@implementation TLTMojiInputView

#pragma mark -
#pragma mark <TLTMojiScrollerDelegate>

- (NSOrderedSet *)scrollerWillPresentImages:(TLTMojiScroller *)scroller
{
    TLTMojiCatalogDTO *dto = self.selectedCatalogDTO;
    return dto.getTMojiIcons;
}

#pragma mark -
#pragma mark <TLTMojiCategoryBarDelegate>

- (NSOrderedSet *)categoryBarWillPresentCategories:
    (TLTMojiCategoryBar *)categoryBar
{
    NSMutableOrderedSet *categories = [NSMutableOrderedSet orderedSet];

    for (TLTMojiCatalogDTO *dto in self.catalogDTOs)
        [categories addObject:dto.catalogIcon];
    return categories;
}

- (void)        category:(TLTMojiCategoryBar *)categoryBar
      wasTappedWithImage:(UIImage *)image
{
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"catalogIcon == %@", image];
    NSArray *dtos = [[self.catalogDTOs array]
        filteredArrayUsingPredicate:predicate];

    if ([dtos count] > 0) {
        self.selectedCatalogDTO = dtos[0];
        [self.scroller updateScroller];
    }
}

#pragma mark -
#pragma mark TLTMojiInputView

// Outlets
@synthesize scroller;
@synthesize categoryBar;
// Models
@synthesize catalogDTOs;
@synthesize selectedCatalogDTO;

-(TLTMojiCatalogDTO *)selectedCatalogDTO
{
    if (selectedCatalogDTO == nil) {
        selectedCatalogDTO = self.catalogDTOs[0];
    }
    return selectedCatalogDTO;
}

- (id)initWithCatalogDTOs:(NSOrderedSet *)theCatalogDTOs
                 delegate:(id <TLTMojiInputViewDelegate>)theDelegate
{
    CGRect frame = CGRectZero;

    frame.origin = CGPointMake(.0, .0);
    frame.size = kTLTMojiInpuViewSize;
    if ((self = [super initWithFrame:frame]) != nil) {
        [self basicSetupWithCatalogDTOs:theCatalogDTOs];
        [self scrollerSetup];
        [self categoryBarSetup];
        self.delegate = theDelegate;
    }
    return self;
}

- (void)TMojiButtonPressed:(UIButton *)sender
{
    UIImage *buttonImage= sender.imageView.image;
    NSString *TMojiName = [self.selectedCatalogDTO
        getNameForTMojiImage:buttonImage];
    [self.delegate sendTmojiWithText:TMojiName];
}

- (void)basicSetupWithCatalogDTOs:(NSOrderedSet *)theCatalogDTOs
{
    self.backgroundColor = TL_TMOJI_INPUT_BACKGROUND_TINT;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.catalogDTOs = theCatalogDTOs;
}

- (void)scrollerSetup
{
    CGRect frame = CGRectZero;
    CGSize scrollerSize = kTLTMojiInputViewScrollerSize;

    frame.origin = CGPointMake(.0, .0);
    frame.size = scrollerSize;

    TLTMojiScroller *scrollerView =
        [[TLTMojiScroller alloc] initWithFrame:frame delegate:self];

    self.scroller = scrollerView;
    [self addSubview:scrollerView];
}

- (void)categoryBarSetup
{
    CGRect frame = CGRectZero;
    CGSize categorySize = kTLTMojiInputViewCategoryBarSize;
    CGSize scrollerSize = kTLTMojiInputViewScrollerSize;

    frame.origin = CGPointMake(.0, scrollerSize.height);
    frame.size = categorySize;

    TLTMojiCategoryBar *categoryView =
        [[TLTMojiCategoryBar alloc] initWithFrame:frame delegate:self];

    self.categoryBar = categoryView;
    [self addSubview:categoryView];
}
@end
