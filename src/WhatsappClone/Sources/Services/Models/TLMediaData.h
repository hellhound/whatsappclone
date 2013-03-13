#import <Foundation/Foundation.h>

typedef enum {
    kMessageMediaPhoto,
    kMessageMediaVideo
} TLMessageMediaType;


@interface TLMediaData: NSObject

@property (nonatomic, assign) TLMessageMediaType mediaType;
@property (nonatomic, strong) NSData *data;

+ (TLMediaData *)mediaDataWithData:(NSData *)theData;

- (NSData *)getObjectData;
@end
