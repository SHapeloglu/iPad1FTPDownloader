#import <Foundation/Foundation.h>

@class FTPBrowser;

@protocol FTPBrowserDelegate <NSObject>
- (void)ftpBrowserDidStart:(FTPBrowser *)browser path:(NSString *)path;
- (void)ftpBrowser:(FTPBrowser *)browser didFinishWithItems:(NSArray *)items path:(NSString *)path;
- (void)ftpBrowser:(FTPBrowser *)browser didFailWithError:(NSError *)error;
@end

@interface FTPBrowser : NSObject <NSStreamDelegate> {
    id<FTPBrowserDelegate> _delegate;
    NSInputStream *_inputStream;
    NSMutableData *_data;
    NSString *_path;
    BOOL _finished;
}
@property (nonatomic, assign) id<FTPBrowserDelegate> delegate;

- (void)listHost:(NSString *)host
            port:(NSInteger)port
        username:(NSString *)username
        password:(NSString *)password
            path:(NSString *)path;
- (void)cancel;
@end
