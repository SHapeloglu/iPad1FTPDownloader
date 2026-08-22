#import <Foundation/Foundation.h>

@class FTPDownloader;

@protocol FTPDownloaderDelegate <NSObject>
- (void)ftpDownloaderDidStart:(FTPDownloader *)downloader destination:(NSString *)destination;
- (void)ftpDownloader:(FTPDownloader *)downloader didReceiveBytes:(unsigned long long)totalBytes;
- (void)ftpDownloaderDidFinish:(FTPDownloader *)downloader destination:(NSString *)destination bytes:(unsigned long long)totalBytes;
- (void)ftpDownloader:(FTPDownloader *)downloader didFailWithError:(NSError *)error;
@end

@interface FTPDownloader : NSObject <NSStreamDelegate> {
    id<FTPDownloaderDelegate> _delegate;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSString *_destinationPath;
    unsigned long long _totalBytes;
    BOOL _finished;
}
@property (nonatomic, assign) id<FTPDownloaderDelegate> delegate;

- (void)downloadHost:(NSString *)host
                port:(NSInteger)port
            username:(NSString *)username
            password:(NSString *)password
          remotePath:(NSString *)remotePath
     destinationPath:(NSString *)destinationPath;
- (void)cancel;
@end
