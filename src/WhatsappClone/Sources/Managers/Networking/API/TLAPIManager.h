#import <Foundation/Foundation.h>

@protocol TLAPIClient;

@interface TLAPIManager: NSObject

@property (atomic, strong, readonly) id<TLAPIClient> client;

+ (TLAPIManager *)sharedInstanceWithClientProtocol:(Protocol *)protocol;
@end

typedef void (^TLClientSuccessBlock)(NSURLRequest *request,
    NSHTTPURLResponse *response, id userInfo);
typedef void (^TLClientFailureBlock)(NSURLRequest *request,
    NSHTTPURLResponse *response, NSError *error, id userInfo);

@protocol TLClientBridge <NSObject>

- (void)sendBridgeWithRequest:(NSURLRequest *)request
                      success:(TLClientSuccessBlock)successBlock
                      failure:(TLClientFailureBlock)failureBlock;
@end

@protocol TLAPIClient <NSObject>

@property (atomic, copy) TLClientSuccessBlock success; 
@property (atomic, copy) TLClientFailureBlock failure;
@property (atomic, weak) id<TLClientBridge> bridge;

- (void)postToURL:(NSURL *)url
       parameters:(NSDictionary *)parameters
       withMethod:(NSString *)method;

- (void)postToURL:(NSURL *)url
       parameters:(NSDictionary *)parameters;
@end

// Public interface to initiate the registration workflow

@protocol TLAPIRegistrationClient <TLAPIClient>

- (void)postPhoneNumber:(NSString *)phoneNumber;
- (void)postVerificationCode:(NSString *)verificationCode
             forPhoneNumber:(NSString *)phoneNumber;
@end
