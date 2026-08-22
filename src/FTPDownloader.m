#import "FTPDownloader.h"
#import <CFNetwork/CFNetwork.h>

@implementation FTPDownloader
@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        _totalBytes = 0;
        _finished = YES;
    }
    return self;
}

- (void)dealloc {
    [self cancel];
    [_destinationPath release];
    [super dealloc];
}

- (void)downloadHost:(NSString *)host
                port:(NSInteger)port
            username:(NSString *)username
            password:(NSString *)password
          remotePath:(NSString *)remotePath
     destinationPath:(NSString *)destinationPath {

    [self cancel];
    _finished = NO;
    _totalBytes = 0;

    NSString *path = remotePath;
    if (![path hasPrefix:@"/"]) path = [@"/" stringByAppendingString:path];

    NSString *urlString = [NSString stringWithFormat:@"ftp://%@:%ld%@", host, (long)port, path];
    NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:escaped];

    if (!url) {
        NSError *e = [NSError errorWithDomain:@"iPad1FTPDownloader" code:1001
                                     userInfo:[NSDictionary dictionaryWithObject:@"Geçersiz FTP adresi."
                                                                          forKey:NSLocalizedDescriptionKey]];
        if ([_delegate respondsToSelector:@selector(ftpDownloader:didFailWithError:)])
            [_delegate ftpDownloader:self didFailWithError:e];
        return;
    }

    CFReadStreamRef ftpStream = CFReadStreamCreateWithFTPURL(NULL, (CFURLRef)url);
    if (!ftpStream) {
        NSError *e = [NSError errorWithDomain:@"iPad1FTPDownloader" code:1002
                                     userInfo:[NSDictionary dictionaryWithObject:@"FTP bağlantı akışı oluşturulamadı."
                                                                          forKey:NSLocalizedDescriptionKey]];
        if ([_delegate respondsToSelector:@selector(ftpDownloader:didFailWithError:)])
            [_delegate ftpDownloader:self didFailWithError:e];
        return;
    }

    if ([username length] > 0)
        CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPUserName, (CFStringRef)username);
    if ([password length] > 0)
        CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPPassword, (CFStringRef)password);

    CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanTrue);

    _inputStream = (NSInputStream *)ftpStream;
    [_inputStream setDelegate:self];

    [_destinationPath release];
    _destinationPath = [destinationPath copy];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [_destinationPath stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:dir]) {
        NSError *mkdirError = nil;
        if (![fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&mkdirError]) {
            CFRelease(ftpStream);
            _inputStream = nil;
            if ([_delegate respondsToSelector:@selector(ftpDownloader:didFailWithError:)])
                [_delegate ftpDownloader:self didFailWithError:mkdirError];
            return;
        }
    }

    if ([fm fileExistsAtPath:_destinationPath])
        [fm removeItemAtPath:_destinationPath error:nil];

    _outputStream = [[NSOutputStream alloc] initToFileAtPath:_destinationPath append:NO];
    [_outputStream open];

    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];

    if ([_delegate respondsToSelector:@selector(ftpDownloaderDidStart:destination:)])
        [_delegate ftpDownloaderDidStart:self destination:_destinationPath];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream != _inputStream || _finished) return;

    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[16384];
        NSInteger bytesRead = [_inputStream read:buffer maxLength:sizeof(buffer)];
        if (bytesRead > 0) {
            NSInteger offset = 0;
            while (offset < bytesRead) {
                NSInteger written = [_outputStream write:&buffer[offset] maxLength:(NSUInteger)(bytesRead - offset)];
                if (written <= 0) {
                    NSError *e = [_outputStream streamError];
                    if (!e) e = [NSError errorWithDomain:@"iPad1FTPDownloader" code:1003
                                                userInfo:[NSDictionary dictionaryWithObject:@"Dosyaya yazma hatası."
                                                                                     forKey:NSLocalizedDescriptionKey]];
                    [self fail:e];
                    return;
                }
                offset += written;
            }
            _totalBytes += (unsigned long long)bytesRead;
            if ([_delegate respondsToSelector:@selector(ftpDownloader:didReceiveBytes:)])
                [_delegate ftpDownloader:self didReceiveBytes:_totalBytes];
        }
    } else if (eventCode == NSStreamEventEndEncountered) {
        [self finish];
    } else if (eventCode == NSStreamEventErrorOccurred) {
        NSError *e = [_inputStream streamError];
        if (!e) e = [NSError errorWithDomain:@"iPad1FTPDownloader" code:1004
                                    userInfo:[NSDictionary dictionaryWithObject:@"FTP indirme hatası."
                                                                         forKey:NSLocalizedDescriptionKey]];
        [self fail:e];
    }
}

- (void)finish {
    if (_finished) return;
    _finished = YES;

    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [_outputStream close];

    [_inputStream release]; _inputStream = nil;
    [_outputStream release]; _outputStream = nil;

    if ([_delegate respondsToSelector:@selector(ftpDownloaderDidFinish:destination:bytes:)])
        [_delegate ftpDownloaderDidFinish:self destination:_destinationPath bytes:_totalBytes];
}

- (void)fail:(NSError *)error {
    if (_finished) return;
    _finished = YES;

    if (_inputStream) {
        [_inputStream close];
        [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream setDelegate:nil];
        [_inputStream release]; _inputStream = nil;
    }
    if (_outputStream) {
        [_outputStream close];
        [_outputStream release]; _outputStream = nil;
    }

    if ([_delegate respondsToSelector:@selector(ftpDownloader:didFailWithError:)])
        [_delegate ftpDownloader:self didFailWithError:error];
}

- (void)cancel {
    if (_inputStream) {
        [_inputStream close];
        [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream setDelegate:nil];
        [_inputStream release]; _inputStream = nil;
    }
    if (_outputStream) {
        [_outputStream close];
        [_outputStream release]; _outputStream = nil;
    }
    _finished = YES;
}
@end
