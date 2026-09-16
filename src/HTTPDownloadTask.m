#import "HTTPDownloadTask.h"

#define IP1_DOWNLOADS @"/var/mobile/Media/iPad1Files/Downloads"

@implementation HTTPDownloadTask
@synthesize delegate=_delegate;
- (NSString *)finalPath { return _finalPath; }

- (BOOL)ensureDownloads {
    BOOL isDir=NO;
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:IP1_DOWNLOADS isDirectory:&isDir]) return isDir;
    return [fm createDirectoryAtPath:IP1_DOWNLOADS withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString *)sanitizedFilename:(NSString *)name {
    if(![name length]) name=@"download.bin";
    name=[name lastPathComponent];
    name=[name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    name=[name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    if(![name length] || [name isEqualToString:@"."] || [name isEqualToString:@".."]) name=@"download.bin";
    return name;
}

- (NSString *)uniquePathForFilename:(NSString *)filename {
    NSFileManager *fm=[NSFileManager defaultManager];
    NSString *candidate=[IP1_DOWNLOADS stringByAppendingPathComponent:filename];
    if(![fm fileExistsAtPath:candidate] && ![fm fileExistsAtPath:[candidate stringByAppendingString:@".part"]]) return candidate;
    NSString *ext=[filename pathExtension];
    NSString *base=[filename stringByDeletingPathExtension];
    NSInteger i=1;
    while(i<10000){
        NSString *n=[ext length]?[NSString stringWithFormat:@"%@ (%ld).%@",base,(long)i,ext]:[NSString stringWithFormat:@"%@ (%ld)",base,(long)i];
        candidate=[IP1_DOWNLOADS stringByAppendingPathComponent:n];
        if(![fm fileExistsAtPath:candidate] && ![fm fileExistsAtPath:[candidate stringByAppendingString:@".part"]]) return candidate;
        i++;
    }
    return [IP1_DOWNLOADS stringByAppendingPathComponent:[NSString stringWithFormat:@"download-%f.bin",[NSDate timeIntervalSinceReferenceDate]]];
}

- (void)downloadURL:(NSURL *)url {
    [self cancel];
    if(!url || ![self ensureDownloads]){
        NSError *e=[NSError errorWithDomain:@"iPad1Downloader" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Downloads klasörü hazırlanamadı." forKey:NSLocalizedDescriptionKey]];
        if([_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:e];
        return;
    }
    [_url release]; _url=[url retain];
    _cancelled=NO; _responseAccepted=NO; _receivedBytes=0; _expectedBytes=-1;
    _startedAt=[NSDate timeIntervalSinceReferenceDate];
    NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [r setHTTPMethod:@"GET"];
    _connection=[[NSURLConnection alloc] initWithRequest:r delegate:self startImmediately:YES];
}

- (void)cancel {
    _cancelled=YES;
    [_connection cancel]; [_connection release]; _connection=nil;
    if(_fileHandle){ [_fileHandle closeFile]; [_fileHandle release]; _fileHandle=nil; }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    (void)connection;
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSInteger status=[(NSHTTPURLResponse *)response statusCode];
        if(status<200 || status>=300){
            NSError *e=[NSError errorWithDomain:@"iPad1Downloader.HTTP" code:status userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"HTTP %ld",(long)status] forKey:NSLocalizedDescriptionKey]];
            [_connection cancel];
            if([_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:e];
            return;
        }
    }
    NSString *filename=[response suggestedFilename];
    if(![filename length]) filename=[[_url path] lastPathComponent];
    filename=[self sanitizedFilename:filename];
    [_finalPath release]; _finalPath=[[self uniquePathForFilename:filename] copy];
    [_partialPath release]; _partialPath=[[_finalPath stringByAppendingString:@".part"] copy];
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm removeItemAtPath:_partialPath error:nil];
    [fm createFileAtPath:_partialPath contents:nil attributes:nil];
    _fileHandle=[[NSFileHandle fileHandleForWritingAtPath:_partialPath] retain];
    if(!_fileHandle){
        NSError *e=[NSError errorWithDomain:@"iPad1Downloader" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Geçici dosya açılamadı." forKey:NSLocalizedDescriptionKey]];
        [_connection cancel];
        if([_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:e];
        return;
    }
    _expectedBytes=[response expectedContentLength];
    _responseAccepted=YES;
    if([_delegate respondsToSelector:@selector(httpDownloadTaskDidStart:destination:expectedBytes:)]) [_delegate httpDownloadTaskDidStart:self destination:_finalPath expectedBytes:_expectedBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    (void)connection;
    if(!_responseAccepted || !_fileHandle || _cancelled) return;
    @try { [_fileHandle writeData:data]; }
    @catch(NSException *ex){
        NSError *e=[NSError errorWithDomain:@"iPad1Downloader" code:3 userInfo:[NSDictionary dictionaryWithObject:[ex reason]?:@"Disk yazma hatası" forKey:NSLocalizedDescriptionKey]];
        [self cancel];
        if([_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:e];
        return;
    }
    _receivedBytes += [data length];
    NSTimeInterval elapsed=[NSDate timeIntervalSinceReferenceDate]-_startedAt;
    double speed=elapsed>.05?((double)_receivedBytes/elapsed):0;
    if([_delegate respondsToSelector:@selector(httpDownloadTask:didReceiveBytes:totalBytes:bytesPerSecond:)]) [_delegate httpDownloadTask:self didReceiveBytes:_receivedBytes totalBytes:_expectedBytes bytesPerSecond:speed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    (void)connection;
    if(_cancelled || !_responseAccepted) return;
    [_fileHandle synchronizeFile]; [_fileHandle closeFile]; [_fileHandle release]; _fileHandle=nil;
    NSError *e=nil;
    if(![[NSFileManager defaultManager] moveItemAtPath:_partialPath toPath:_finalPath error:&e]){
        if([_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:e];
        return;
    }
    if([_delegate respondsToSelector:@selector(httpDownloadTaskDidFinish:destination:bytes:)]) [_delegate httpDownloadTaskDidFinish:self destination:_finalPath bytes:_receivedBytes];
    [_connection release]; _connection=nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    (void)connection;
    if(_fileHandle){ [_fileHandle closeFile]; [_fileHandle release]; _fileHandle=nil; }
    [_connection release]; _connection=nil;
    if(!_cancelled && [_delegate respondsToSelector:@selector(httpDownloadTask:didFailWithError:)]) [_delegate httpDownloadTask:self didFailWithError:error];
}

- (void)dealloc {
    _delegate=nil; [self cancel];
    [_url release]; [_partialPath release]; [_finalPath release];
    [super dealloc];
}
@end
