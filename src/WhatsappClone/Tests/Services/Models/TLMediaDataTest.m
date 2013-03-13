#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "Application/TLConstants.h"
#import "TLTestConstants.h"
#import "Services/Models/TLMediaData.h"

@interface TLMediaDataTest: SenTestCase
@end

@implementation TLMediaDataTest

static TLMessageMediaType const kTestMediaType = kMessageMediaPhoto;

- (void)testMediaTypeShouldReturnATLMessageMediaType
{
    //setup
    TLMediaData *mediaData = [[TLMediaData alloc] init];

    //action
    mediaData.mediaType = kTestMediaType;

    //verify
    STAssertEquals(mediaData.mediaType, kTestMediaType,
            @"The media types are not equal");
}

- (void)testDataShouldReturnNSData
{
    //setup
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    NSData *testData = [[NSData alloc] init];

    //action
    mediaData.data = testData;

    //verify
    assertThat(mediaData.data, equalTo(testData));
}

- (void)testGetObjectDataShouldReturnANSData
{
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    NSData *testData = [[NSData alloc] init];

    //action
    mediaData.mediaType = kTestMediaType;
    mediaData.data = testData;

    //verify
    assertThat([mediaData getObjectData], instanceOf([NSData class]));
}

- (void)testEncodingAndDecodingObjectShouldHaveSameProperties
{
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    NSData *testData = [[NSData alloc] init];

    //action
    mediaData.mediaType = kTestMediaType;
    mediaData.data = testData;
    NSData *currentData = [mediaData getObjectData];
    TLMediaData *newData = [TLMediaData mediaDataWithData:currentData];

    //verify
    STAssertTrue([newData.data isEqualToData:mediaData.data],
            @"the data properties are diferent");
    STAssertEquals(mediaData.mediaType, newData.mediaType,
            @"The media types are diferent");
}
@end
