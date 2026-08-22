#import <Foundation/Foundation.h>
typedef enum { LegacyProtocolFTP=0, LegacyProtocolFTPS=1, LegacyProtocolSFTP=2 } LegacyProtocol;
@interface LegacySecureTransport : NSObject
+ (BOOL)isProtocolAvailable:(LegacyProtocol)p;
+ (NSString *)messageForProtocol:(LegacyProtocol)p;
@end
