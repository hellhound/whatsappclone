#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"
#import "Categories/NSString+TLURLEncoding.h"
#import "Managers/Networking/API/TLAPIManager.h"

static NSString *const kAURL = @"http://www.example.com";
static NSString *const kAUnencodedParameter1 = @"param1\u27A6";
static NSString *const kAUnencodedParameter2 = @"param2\u20B5";
static NSString *const kAQueryString = @"param1=%@&param2=%@";
static NSString *const kAPhoneNumber = @"+13019999999";
static NSString *const kAPhoneNumberEscaped = @"\%2B13019999999";
static NSString *const kAVerificationCode = @"++++++";
static NSString *const kAVerificationCodeEscaped = @"\%2B\%2B\%2B\%2B\%2B\%2B";
// Endpoints
static NSString *const
    kRegistrationPhoneEndpoint = @"verificationCode?phone=%@";
static NSString *const
    kRegistrationVerificationCodeEndpoint = @"verificationCode?phone=%@&"
    @"verificationCode=%@";

@interface TLAPIManagerTest: SenTestCase <TLClientBridge>

@property (nonatomic, strong) NSURLRequest *returnedRequest;

- (TLAPIManager *)getAPIManager;
- (TLClientSuccessBlock)getSuccessBlock;
- (TLClientFailureBlock)getFailureBlock;
- (void)assertThatRequest:(NSURLRequest *)request
                 equalsTo:(NSURLRequest *)returnedRequest;
@end

@interface TLAPIManagerTest (TLGenerciClientTest)

- (NSURL *)getURL;
- (NSDictionary *)getParameters;
- (NSData *)getDataParameters;
- (NSURLRequest *)getRequest;
- (id<TLAPIClient>)getAPIClient;
@end

@interface TLAPIManagerTest (TLRegistrationClientTest)

- (TLAPIManager *)getAPIManagerForRegistration;
- (id<TLAPIRegistrationClient>)getAPIRegistrationClient;
- (NSURLRequest *)getRequestForRegistrationURL:(NSURL *)url;
@end

@implementation TLAPIManagerTest

#pragma mark -
#pragma mark <TLClientBridge>

- (void)sendBridgeWithRequest:(NSURLRequest *)request
                      success:(TLClientSuccessBlock)successBlock
                      failure:(TLClientFailureBlock)failureBlock
{
    self.returnedRequest = request;
}

#pragma mark -
#pragma mark TLAPIManagerTest

- (TLAPIManager *)getAPIManager
{
    return
        [TLAPIManager sharedInstanceWithClientProtocol:@protocol(TLAPIClient)];
}

- (TLClientSuccessBlock)getSuccessBlock
{
    return ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {};
}

- (TLClientFailureBlock)getFailureBlock
{
    return ^(NSURLRequest *request ,NSHTTPURLResponse *response, NSError *error,
        id JSON) {};
}

- (void)assertThatRequest:(NSURLRequest *)returnedRequest
                 equalsTo:(NSURLRequest *)request
{
    assertThat([returnedRequest URL], equalTo([request URL]));
    assertThat([returnedRequest HTTPMethod], equalTo([request HTTPMethod]));
    assertThat([returnedRequest HTTPBody], equalTo([request HTTPBody]));
    assertThat([returnedRequest valueForHTTPHeaderField:@"Content-Length"],
        equalTo([request valueForHTTPHeaderField:@"Content-Length"]));
    assertThat([returnedRequest valueForHTTPHeaderField:@"Current-Type"],
        equalTo([request valueForHTTPHeaderField:@"Current-Type"]));
}

#pragma mark -
#pragma mark TLAPIManagerTest (TLGenericClientTest)

- (NSURL *)getURL
{
    return [NSURL URLWithString:kAURL];
}

- (NSDictionary *)getParameters
{
    NSDictionary *parameters = @{
        @"param1": kAUnencodedParameter1,
        @"param2": kAUnencodedParameter2
    };
    return parameters;
}

- (NSData *)getDataParameters
{
    NSString *param1 = [kAUnencodedParameter1 URLEncodedString];
    NSString *param2 = [kAUnencodedParameter2 URLEncodedString];
    NSString *query = [NSString stringWithFormat:kAQueryString, param1, param2];

    return [query dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURLRequest *)getRequest
{
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self getURL]];
    NSData *post = [self getDataParameters];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];

    [request setHTTPMethod:TL_DEFAULT_PARAMETER_METHOD];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded"
        forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:post];
    return request;
}

- (id<TLAPIClient>)getAPIClient
{
    TLAPIManager *manager = [self getAPIManager];
    id<TLAPIClient> client = manager.client;
    
    return client;
}

#pragma mark -
#pragma mark TLAPIManagerTest (TLRegistrationClientTest)

- (TLAPIManager *)getAPIManagerForRegistration
{
    return [TLAPIManager sharedInstanceWithClientProtocol:
        @protocol(TLAPIRegistrationClient)];
}

- (id<TLAPIRegistrationClient>)getAPIRegistrationClient
{
    TLAPIManager *manager = [self getAPIManagerForRegistration];
    id<TLAPIRegistrationClient> client =
        (id<TLAPIRegistrationClient>)manager.client;

    return client;
}

- (NSURLRequest *)getRequestForRegistrationURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:TL_DEFAULT_PARAMETER_METHOD];
    [request setHTTPBody:[NSData data]];
    [request setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded"
        forHTTPHeaderField:@"Current-Type"];
    return request;
}

- (NSURLRequest *)getRequestForVerificationURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:TL_PUT_PARAMETER_METHOD];
    [request setHTTPBody:[NSData data]];
    [request setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded"
        forHTTPHeaderField:@"Current-Type"];
    return request;
}

#pragma mark -
#pragma mark Tests

- (void)setUp
{
    self.returnedRequest = nil;
}

- (void)testSharedInstanceWithClientProtocolShouldReturnATLAPIManager
{
    // setup
    TLAPIManager *manager = nil;

    // action
    manager =
        [TLAPIManager sharedInstanceWithClientProtocol:@protocol(TLAPIClient)];

    // assert
    assertThat(manager, instanceOf([TLAPIManager class]));
}

- (void)testSharedInstanceWithClientProtocolShouldReturnATLAPIManagerSingleton
{
    // setup
    TLAPIManager *manager = [self getAPIManager];

    // action
    TLAPIManager *returned =
        [TLAPIManager sharedInstanceWithClientProtocol:@protocol(TLAPIClient)];

    // assert
    assertThat(returned, equalTo(manager));
}

- (void)testSharedInstanceWithClientProtocolShouldReturnSameAsCopy
{
    // setup

    // action
    TLAPIManager *manager =
        [TLAPIManager sharedInstanceWithClientProtocol:@protocol(TLAPIClient)];

    // assert
    assertThat(manager, equalTo([manager copy]));
}

- (void)testClientShouldReturnAClient
{
    // setup
    // At least one client should implement the TLAPIClient protocol
    TLAPIManager *manager =
        [TLAPIManager sharedInstanceWithClientProtocol:@protocol(TLAPIClient)];

    // action
    id<TLAPIClient> client = manager.client;
    
    // asssert
    assertThat(client, conformsTo(@protocol(TLAPIClient)));
}

- (void)testClientPostToURLParametersShouldCallSendBridgeWithRequestSuccessFailure
{
    // setup
    id<TLAPIClient> client = [self getAPIClient];
    // this class conforms to TLClientBridge to capture the request
    id<TLClientBridge> bridge = self;
    NSDictionary *parameters = [self getParameters];
    NSURL *url = [self getURL];
    NSURLRequest *request = [self getRequest];

    client.bridge = bridge;

    // action
    [client postToURL:url parameters:parameters];

    // assert
    [self assertThatRequest:self.returnedRequest equalsTo:request];
}

- (void)testClientPostPhoneNumberShouldCallSendBridgeWithRequestSuccessFailure
{
    // setup
    id<TLAPIRegistrationClient> client = [self getAPIRegistrationClient];
    // this class conforms to TLClientBridge to capture the request
    id<TLClientBridge> bridge = self;
    NSURL *url = URL(ENDPOINT_FROM_STRING(kRegistrationPhoneEndpoint),
        kAPhoneNumberEscaped);
    NSURLRequest *request = [self getRequestForRegistrationURL:url];

    client.bridge = bridge;

    // action
    [client postPhoneNumber:kAPhoneNumber];

    // assert
    [self assertThatRequest:self.returnedRequest equalsTo:request];
}

- (void)testClientPostVerificationCodeForPhoneNumberShouldCallSendBridgeWithRequestSuccessFailure
{
    // setup
    id<TLAPIRegistrationClient> client = [self getAPIRegistrationClient];
    // this class conforms to TLClientBridge to capture the request
    id<TLClientBridge> bridge = self;
    NSURL *url =
        URL(ENDPOINT_FROM_STRING(kRegistrationVerificationCodeEndpoint),
        kAPhoneNumberEscaped, kAVerificationCodeEscaped);
    NSURLRequest *request = [self getRequestForVerificationURL:url];

    client.bridge = bridge;

    // action
    [client postVerificationCode:kAVerificationCode
        forPhoneNumber:kAPhoneNumber];

    // assert
    [self assertThatRequest:self.returnedRequest equalsTo:request];
}
@end
