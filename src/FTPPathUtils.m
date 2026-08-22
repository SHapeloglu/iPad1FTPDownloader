#import "FTPPathUtils.h"

@implementation FTPPathUtils

+ (NSString *)normalizedRemoteDirectoryPath:(NSString *)path {
    NSString *p = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![p length]) return @"/";
    if (![p hasPrefix:@"/"]) p = [@"/" stringByAppendingString:p];
    while ([p rangeOfString:@"//"].location != NSNotFound)
        p = [p stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    if (![p isEqualToString:@"/"] && ![p hasSuffix:@"/"])
        p = [p stringByAppendingString:@"/"];
    return p;
}

+ (NSString *)remotePathForName:(NSString *)name inDirectory:(NSString *)directory {
    NSString *base = [self normalizedRemoteDirectoryPath:directory];
    return [base stringByAppendingString:(name ?: @"")];
}

@end
