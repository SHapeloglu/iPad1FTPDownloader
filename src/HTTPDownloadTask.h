#import <Foundation/Foundation.h>

@class HTTPDownloadTask;

@protocol HTTPDownloadTaskDelegate <NSObject>
- (void)httpDownloadTaskDidStart:(HTTPDownloadTask *)task destination:(NSString *)destination expectedBytes:(long long)expectedBytes;
- (void)httpDownloadTask:(HTTPDownloadTask *)task didReceiveBytes:(unsigned long long)received totalBytes:(long long)total bytesPerSecond:(double)speed;
- (void)httpDownloadTaskDidFinish:(HTTPDownloadTask *)task destination:(NSString *)destination bytes:(unsigned long long)bytes;
- (void)httpDownloadTask:(HTTPDownloadTask *)task didFailWithError:(NSError *)error;
@end

@interface HTTPDownloadTask : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    id<HTTPDownloadTaskDelegate> _delegate;
    NSURL *_url;
    NSURLConnection *_connection;
    NSFileHandle *_fileHandle;
    NSString *_partialPath;
    NSString *_finalPath;
    unsigned long long _receivedBytes;
    long long _expectedBytes;
    NSTimeInterval _startedAt;
    BOOL _cancelled;
    BOOL _responseAccepted;
}
@property(nonatomic,assign) id<HTTPDownloadTaskDelegate> delegate;
@property(nonatomic,readonly) NSString *finalPath;
- (void)downloadURL:(NSURL *)url;
- (void)cancel;
@end
