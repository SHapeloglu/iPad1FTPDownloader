#import "FTPUploader.h"
#import <CFNetwork/CFNetwork.h>
@implementation FTPUploader
@synthesize delegate = _delegate;
- (id)init { self=[super init]; if(self)_finished=YES; return self; }
- (void)dealloc { [self cancel]; [_remotePath release]; [super dealloc]; }
- (void)uploadFile:(NSString *)localPath host:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password remotePath:(NSString *)remotePath {
    [self cancel]; _finished=NO; _sentBytes=0; _bufferLength=0; _bufferOffset=0; _startTime=[NSDate timeIntervalSinceReferenceDate];
    NSDictionary *attrs=[[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:nil];
    _totalBytes=[[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    NSString *path=[remotePath hasPrefix:@"/"]?remotePath:[@"/" stringByAppendingString:remotePath];
    NSString *u=[[NSString stringWithFormat:@"ftp://%@:%ld%@",host,(long)port,path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:u];
    if(!url){ [self failMessage:@"Geçersiz FTP upload adresi." code:3001]; return; }
    CFWriteStreamRef s=CFWriteStreamCreateWithFTPURL(NULL,(CFURLRef)url);
    if(!s){ [self failMessage:@"FTP upload akışı oluşturulamadı." code:3002]; return; }
    if([username length]>0) CFWriteStreamSetProperty(s,kCFStreamPropertyFTPUserName,(CFStringRef)username);
    if([password length]>0) CFWriteStreamSetProperty(s,kCFStreamPropertyFTPPassword,(CFStringRef)password);
    CFWriteStreamSetProperty(s,kCFStreamPropertyFTPAttemptPersistentConnection,kCFBooleanTrue);
    _ftpStream=(NSOutputStream *)s; [_ftpStream setDelegate:self];
    _fileStream=[[NSInputStream alloc] initWithFileAtPath:localPath]; [_fileStream open];
    [_remotePath release]; _remotePath=[path copy];
    [_ftpStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode]; [_ftpStream open];
    if([_delegate respondsToSelector:@selector(ftpUploaderDidStart:source:totalBytes:)]) [_delegate ftpUploaderDidStart:self source:localPath totalBytes:_totalBytes];
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)e {
    if(aStream!=_ftpStream || _finished) return;
    if(e==NSStreamEventHasSpaceAvailable){
        while([_ftpStream hasSpaceAvailable] && !_finished){
            if(_bufferOffset>=_bufferLength){ _bufferLength=[_fileStream read:_buffer maxLength:sizeof(_buffer)]; _bufferOffset=0;
                if(_bufferLength<0){ [self fail:[_fileStream streamError]]; return; }
                if(_bufferLength==0){ [self finish]; return; }
            }
            NSInteger n=[_ftpStream write:&_buffer[_bufferOffset] maxLength:(NSUInteger)(_bufferLength-_bufferOffset)];
            if(n<0){ [self fail:[_ftpStream streamError]]; return; } if(n==0) return;
            _bufferOffset+=n; _sentBytes+=(unsigned long long)n;
            NSTimeInterval elapsed=[NSDate timeIntervalSinceReferenceDate]-_startTime; double bps=elapsed>0.05?((double)_sentBytes/elapsed):0;
            if([_delegate respondsToSelector:@selector(ftpUploader:didSendBytes:totalBytes:bytesPerSecond:)]) [_delegate ftpUploader:self didSendBytes:_sentBytes totalBytes:_totalBytes bytesPerSecond:bps];
        }
    } else if(e==NSStreamEventErrorOccurred){ [self fail:[_ftpStream streamError]]; }
}
- (void)finish { if(_finished)return; _finished=YES; [_fileStream close]; [_ftpStream close]; [_ftpStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode]; [_ftpStream setDelegate:nil]; [_fileStream release];_fileStream=nil; [_ftpStream release];_ftpStream=nil; if([_delegate respondsToSelector:@selector(ftpUploaderDidFinish:remotePath:bytes:)])[_delegate ftpUploaderDidFinish:self remotePath:_remotePath bytes:_sentBytes]; }
- (void)failMessage:(NSString *)m code:(NSInteger)c { NSError *e=[NSError errorWithDomain:@"iPad1FTPDownloader.Upload" code:c userInfo:[NSDictionary dictionaryWithObject:m forKey:NSLocalizedDescriptionKey]]; [self fail:e]; }
- (void)fail:(NSError *)e { if(!e)e=[NSError errorWithDomain:@"iPad1FTPDownloader.Upload" code:3999 userInfo:[NSDictionary dictionaryWithObject:@"FTP upload hatası." forKey:NSLocalizedDescriptionKey]]; if(_finished)return; _finished=YES; if(_fileStream){[_fileStream close];[_fileStream release];_fileStream=nil;} if(_ftpStream){[_ftpStream close];[_ftpStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];[_ftpStream setDelegate:nil];[_ftpStream release];_ftpStream=nil;} if([_delegate respondsToSelector:@selector(ftpUploader:didFailWithError:)])[_delegate ftpUploader:self didFailWithError:e]; }
- (void)cancel { if(_fileStream){[_fileStream close];[_fileStream release];_fileStream=nil;} if(_ftpStream){[_ftpStream close];[_ftpStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];[_ftpStream setDelegate:nil];[_ftpStream release];_ftpStream=nil;} _finished=YES; }
@end
