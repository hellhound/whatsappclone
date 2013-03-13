#import <Foundation/Foundation.h>

#import "TLBaseJSONClient.h"

// avoids warnings
@protocol TLAPIClient;

@interface TLRegistrationClient: TLBaseJSONClient <TLAPIRegistrationClient>
@end
