#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLTMojiScroller.h"
#import "TLTMojiCategoryBar.h"

@protocol TLTMojiInputViewDelegate;

@interface TLTMojiInputView: UIView <TLTMojiScrollerDelegate,
    TLTMojiCategoryBarDelegate>

- (id)initWithCatalogDTOs:(NSOrderedSet *)catalogDTOs
                 delegate:(id <TLTMojiInputViewDelegate>)theDelegate;
- (void)TMojiButtonPressed:(UIButton *)sender;
@end

@protocol TLTMojiInputViewDelegate <NSObject>

- (void)sendTmojiWithText:(NSString *)tmojiText;
@end
