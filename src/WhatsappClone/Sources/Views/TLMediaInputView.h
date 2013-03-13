#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@protocol TLMediaInputViewDelegate;

@interface TLMediaInputView: UIView <UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, MWPhotoBrowserDelegate>

- (id)initWithDelegate:(id<TLMediaInputViewDelegate>)delegate;
@end

@protocol TLMediaInputViewDelegate <NSObject>

- (void)sendImage:(UIImage *)image;
- (void)sendVideoURL:(NSURL *)videoURL;

@end
