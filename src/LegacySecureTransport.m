#import "LegacySecureTransport.h"
@implementation LegacySecureTransport
+ (BOOL)isProtocolAvailable:(LegacyProtocol)p { if(p==LegacyProtocolFTP)return YES;
#ifdef ENABLE_LIBSSH2
if(p==LegacyProtocolSFTP)return YES;
#endif
return NO; }
+ (NSString *)messageForProtocol:(LegacyProtocol)p { if(p==LegacyProtocolFTP)return @"FTP hazır."; if(p==LegacyProtocolSFTP){
#ifdef ENABLE_LIBSSH2
return @"SFTP/libssh2 etkin.";
#else
return @"SFTP için libssh2 kütüphanesini projeye ekleyip ENABLE_LIBSSH2 açılmalıdır.";
#endif
} return @"FTPS, iOS 5 CFFTPStream içinde hazır değildir; ayrı TLS FTP transport katmanı gerekir."; }
@end
