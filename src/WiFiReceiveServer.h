#import <Foundation/Foundation.h>

@class WiFiReceiveServer;

@protocol WiFiReceiveServerDelegate <NSObject>
- (void)wifiReceiveServer:(WiFiReceiveServer *)server didStartWithURL:(NSString *)url;
- (void)wifiReceiveServer:(WiFiReceiveServer *)server didReceiveBytes:(unsigned long long)received totalBytes:(unsigned long long)total filename:(NSString *)filename;
- (void)wifiReceiveServer:(WiFiReceiveServer *)server didFinishPath:(NSString *)path bytes:(unsigned long long)bytes;
- (void)wifiReceiveServer:(WiFiReceiveServer *)server didFailWithMessage:(NSString *)message;
@end

@interface WiFiReceiveServer : NSObject {
    id<WiFiReceiveServerDelegate> _delegate;
    int _listenFD;
    BOOL _running;
    NSInteger _port;
    NSString *_token;
    NSThread *_serverThread;
}
@property(nonatomic,assign) id<WiFiReceiveServerDelegate> delegate;
@property(nonatomic,readonly) BOOL running;
@property(nonatomic,readonly) NSInteger port;
@property(nonatomic,readonly) NSString *token;
- (BOOL)start;
- (void)stop;
- (NSString *)localURL;
@end
