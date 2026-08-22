#import <Foundation/Foundation.h>

@interface FTPPathUtils : NSObject
+ (NSString *)normalizedRemoteDirectoryPath:(NSString *)path;
+ (NSString *)remotePathForName:(NSString *)name inDirectory:(NSString *)directory;
@end
