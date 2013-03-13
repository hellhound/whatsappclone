#import <AFJSONRequestOperation.h>

#import <DDLog.h>
#import <DDTTYLogger.h>

#import "Categories/NSString+TLURLEncoding.h"
#import "Application/TLConstants.h"
#import "TLBaseJSONClient.h"

static NSString *const kKeyValuePair = @"%@=%@";
static NSString *const kPairDelimiter = @"&";

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation TLBaseJSONClient

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        self.bridge = self;
        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    return self;
}

#pragma mark -
#pragma mark <TLAPIClient>

@synthesize success;
@synthesize failure;
@synthesize bridge;

- (id<TLClientBridge>)bridge
{
    @synchronized (self) {
        if (bridge == nil)
            bridge = self;
    }
    return bridge;
}

- (void)postToURL:(NSURL *)url
       parameters:(NSDictionary *)parameters;
{
    [self postToURL:url parameters:parameters
         withMethod:TL_DEFAULT_PARAMETER_METHOD];
}

- (void)postToURL:(NSURL *)url
       parameters:(NSDictionary *)parameters
       withMethod:(NSString *)method
{
    NSMutableArray *queryArray = [NSMutableArray array];

    for (NSString *key in [parameters allKeys]) {
        NSString *pair =
            [NSString stringWithFormat:kKeyValuePair, key,
            [parameters[key] URLEncodedString]];

        [queryArray addObject:pair];
    }

    NSString *query = [queryArray componentsJoinedByString:kPairDelimiter];
    NSData *queryData = [query dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength =
        [NSString stringWithFormat:@"%d", [queryData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:method];
    [request setHTTPBody:queryData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded"
        forHTTPHeaderField:@"Current-Type"];
    [self.bridge sendBridgeWithRequest:request success:self.success
        failure:self.failure];
}

#pragma mark -
#pragma mark <TLAPIClient>

- (void)sendBridgeWithRequest:(NSURLRequest *)request
                      success:(TLClientSuccessBlock)successBlock
                      failure:(TLClientFailureBlock)failureBlock
{
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            DDLogVerbose(@"%@: %@ - JSON:\n%@", THIS_FILE, THIS_METHOD, JSON);
            if (successBlock != NULL)
                successBlock(request, response, JSON);
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
            NSError *error, id JSON)
        {
            DDLogVerbose(@"%@: %@ - JSON:\n%@\nNSError:\n%@", THIS_FILE,
                THIS_METHOD, JSON, error);
            if (failureBlock != NULL)
                failureBlock(request, response, error, JSON);
        }];
    [operation start];
}
@end
