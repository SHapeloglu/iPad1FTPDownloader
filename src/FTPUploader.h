#import <Foundation/Foundation.h>
@class FTPUploader;
@protocol FTPUploaderDelegate <NSObject>
- (void)ftpUploaderDidStart:(FTPUploader *)uploader source:(NSString *)source totalBytes:(unsigned long long)totalBytes;
- (void)ftpUploader:(FTPUploader *)uploader didSendBytes:(unsigned long long)sentBytes totalBytes:(unsigned long long)totalBytes bytesPerSecond:(double)bytesPerSecond;
- (void)ftpUploaderDidFinish:(FTPUploader *)uploader remotePath:(NSString *)remotePath bytes:(unsigned long long)sentBytes;
- (void)ftpUploader:(FTPUploader *)uploader didFailWithError:(NSError *)error;
@end
@interface FTPUploader : NSObject <NSStreamDelegate> {
    id<FTPUploaderDelegate> _delegate;
    NSInputStream *_fileStream;
    NSOutputStream *_ftpStream;
    NSString *_remotePath;
    unsigned long long _sentBytes, _totalBytes;
    NSTimeInterval _startTime;
    uint8_t _buffer[16384];
    NSInteger _bufferLength, _bufferOffset;
    BOOL _finished;
}
@property (nonatomic, assign) id<FTPUploaderDelegate> delegate;
- (void)uploadFile:(NSString *)localPath host:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password remotePath:(NSString *)remotePath;
- (void)cancel;
@end
