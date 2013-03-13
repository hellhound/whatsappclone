#import "NSString+TLPhoneNumber.h"

static NSString *const kToken = @"#";

@interface NSString (TLPhoneNumberPrivate)

- (NSArray *)rangesForNumbers;
- (NSString *)tokenStringForCurrentIndex:(NSUInteger)currentIndex
                                location:(NSUInteger)location;
- (NSString *)substringConstrainedToRange:(NSRange)range;
@end

@implementation NSString (TLPhoneNumberPrivate)

#pragma mark -
#pragma mark NSString (TLPhoneNumberPrivate)

- (NSArray *)rangesForNumbers
{
    NSMutableArray *ranges = [NSMutableArray array];
    NSUInteger currentIndex = 0;
    NSRange currentRange = NSMakeRange(0, 0);
    NSRange searchingRange = NSMakeRange(0, 0);

    do {
        currentIndex = searchingRange.location + searchingRange.length;
        NSString *substring = [self substringFromIndex:currentIndex];

        searchingRange = [substring rangeOfString:kToken];
        
        if (searchingRange.location == NSNotFound)
            continue;
        // searchingRange is relative to currentIndex
        searchingRange.location += currentIndex;
        if (currentIndex == 0) {
            currentRange = searchingRange;
        } else if (currentRange.location + currentRange.length ==
                searchingRange.location) {
            currentRange.length += searchingRange.length;
        } else {
            [ranges addObject:[NSValue valueWithRange:currentRange]];
            currentRange = searchingRange;
        }
    } while (searchingRange.location != NSNotFound);
    if (currentRange.length > 0)
        [ranges addObject:[NSValue valueWithRange:currentRange]];
    return ranges;
}

- (NSString *)tokenStringForCurrentIndex:(NSUInteger)currentIndex
                                location:(NSUInteger)location
{
    NSRange tokenRange = NSMakeRange(currentIndex, location - currentIndex);

    return [self substringWithRange:tokenRange];
}

- (NSString *)substringConstrainedToRange:(NSRange)range
{
    NSUInteger length = [self length];

    if (range.location >= length)
        return @"";
    if (range.location + range.length > length)
        range = NSMakeRange(range.location, length - range.location);
    return [self substringWithRange:range];
}
@end

@implementation NSString (TLPhoneNumber)

#pragma mark -
#pragma mark NSString (TLPhoneNumber)

// Use the pond character '#' to represent a number in the format, everything
// else can be any other character
- (NSString *)stringApplyingFormat:(NSString *)format
{
    NSArray *ranges = [format rangesForNumbers];
    NSString *result = @"";
    NSUInteger currentFormatStringIndex = 0;
    NSUInteger currentInputStringIndex = 0;
    NSRange formatRange = NSMakeRange(0, 0);
    NSUInteger length = [self length];

    for (NSValue *rangeObj in ranges) {
        if (currentInputStringIndex >= length)
            // Remember that we can receive progressive phone numbers from an
            // input view
            break;
        formatRange = [rangeObj rangeValue];

        if (currentFormatStringIndex < formatRange.location)
            result = [result stringByAppendingString:
                [format tokenStringForCurrentIndex:currentFormatStringIndex
                location:formatRange.location]];

        NSRange inputRange =
            NSMakeRange(currentInputStringIndex, formatRange.length);

        result = [result stringByAppendingString:
            [self substringConstrainedToRange:inputRange]];
        currentFormatStringIndex = formatRange.location + formatRange.length;
        currentInputStringIndex += formatRange.length;
    }
    if (currentFormatStringIndex < length)
        result = [result stringByAppendingString:
            [format tokenStringForCurrentIndex:currentFormatStringIndex
            location:formatRange.location]];
    return result;
}

- (NSString *)stringRemovingFormat:(NSString *)format
{
    return [[self componentsSeparatedByCharactersInSet:
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
        componentsJoinedByString:@""];
}
@end
