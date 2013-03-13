#import "TLBaseController.h"

@implementation TLBaseController

#pragma mark -
#pragma mark TLBaseController

@dynamic delegate;

- (id)initWithDelegate:(id<TLBaseControllerDelegate>)theDelegate
{
    if ((self = [super init]) != nil)
        self.delegate = theDelegate;
    return self;
}
@end
