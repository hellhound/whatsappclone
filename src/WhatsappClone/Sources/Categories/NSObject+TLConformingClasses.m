#import <objc/runtime.h>
#import <stdlib.h>

#import "NSObject+TLConformingClasses.h"

@interface NSObject (TLConformingClassesPrivate)
@end

@implementation NSObject (TLConformingClassesPrivate)

#pragma mark -
#pragma mark NSObject (TLConformingClassesPrivate)

+ (NSData *)dataWithClassesCArray
{
    NSInteger numClasses;
    Class *classes = NULL;
    NSData *packagedClasses = nil;

    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        NSUInteger allocSize = sizeof(Class) * numClasses;

        classes = (Class *)malloc(allocSize);
        objc_getClassList(classes, numClasses);
        packagedClasses = [NSData dataWithBytes:classes length:allocSize];
        free(classes);
    }
    return packagedClasses;
}
@end

@implementation NSObject (TLConformingClasses)

#pragma mark -
#pragma mark NSObject (TLConformingClasses)

+ (NSSet *)setWithClassesConformingToProtocol:(Protocol *)protocol
{
    NSData *packagedClasses = [self dataWithClassesCArray];
    Class *classes = (Class *)[packagedClasses bytes];
    NSUInteger length = [packagedClasses length] / sizeof(Class);
    NSMutableSet *classesThatConform = [NSMutableSet setWithCapacity:length];
    NSUInteger i;

    for (i = 0; i < length; i++) {
        Class class = classes[i];
        
        // Doesn't always work! class_respondsToSelector includes Class objects
        // that aren't NSObject subclasses
        if (class_respondsToSelector(class, @selector(conformsToProtocol:)) &&
                [class conformsToProtocol:protocol])
            [classesThatConform addObject:class];
    }
    return classesThatConform;
}
@end
