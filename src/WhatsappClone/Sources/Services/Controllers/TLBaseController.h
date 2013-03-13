#import <Foundation/Foundation.h>

@protocol TLBaseControllerDelegate <NSObject>
@end

@interface TLBaseController: NSObject

@property (nonatomic, weak) id<TLBaseControllerDelegate> delegate;

- (id)initWithDelegate:(id<TLBaseControllerDelegate>)delegate;
@end
