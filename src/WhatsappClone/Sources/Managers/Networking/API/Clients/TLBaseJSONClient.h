#import <Foundation/Foundation.h>

#import <AFHTTPClient.h>

#import "../TLAPIManager.h"

@interface TLBaseJSONClient: AFHTTPClient <TLAPIClient, TLClientBridge>
@end
