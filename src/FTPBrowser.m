#import "FTPBrowser.h"
#import <CFNetwork/CFNetwork.h>

@implementation FTPBrowser
@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) _finished = YES;
    return self;
}

- (void)dealloc {
    [self cancel];
    [_data release];
    [_path release];
    [super dealloc];
}

- (void)listHost:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password path:(NSString *)path {
    [self cancel];
    _finished = NO;

    NSString *safePath = path;
    if ([safePath length] == 0) safePath = @"/";
    if (![safePath hasPrefix:@"/"]) safePath = [@"/" stringByAppendingString:safePath];
    if (![safePath hasSuffix:@"/"]) safePath = [safePath stringByAppendingString:@"/"];

    NSString *urlString = [NSString stringWithFormat:@"ftp://%@:%ld%@", host, (long)port, safePath];
    NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:escaped];

    if (!url) {
        [self fail:[NSError errorWithDomain:@"iPad1FTPDownloader" code:2001
                                   userInfo:[NSDictionary dictionaryWithObject:@"Geçersiz FTP klasör adresi."
                                                                        forKey:NSLocalizedDescriptionKey]]];
        return;
    }

    CFReadStreamRef stream = CFReadStreamCreateWithFTPURL(NULL, (CFURLRef)url);
    if (!stream) {
        [self fail:[NSError errorWithDomain:@"iPad1FTPDownloader" code:2002
                                   userInfo:[NSDictionary dictionaryWithObject:@"FTP klasör akışı oluşturulamadı."
                                                                        forKey:NSLocalizedDescriptionKey]]];
        return;
    }

    if ([username length] > 0)
        CFReadStreamSetProperty(stream, kCFStreamPropertyFTPUserName, (CFStringRef)username);
    if ([password length] > 0)
        CFReadStreamSetProperty(stream, kCFStreamPropertyFTPPassword, (CFStringRef)password);

    CFReadStreamSetProperty(stream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanTrue);

    _inputStream = (NSInputStream *)stream;
    [_inputStream setDelegate:self];

    [_data release];
    _data = [[NSMutableData alloc] init];

    [_path release];
    _path = [safePath copy];

    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];

    if ([_delegate respondsToSelector:@selector(ftpBrowserDidStart:path:)])
        [_delegate ftpBrowserDidStart:self path:_path];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream != _inputStream || _finished) return;

    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[8192];
        NSInteger n = [_inputStream read:buffer maxLength:sizeof(buffer)];
        if (n > 0) [_data appendBytes:buffer length:(NSUInteger)n];
    } else if (eventCode == NSStreamEventEndEncountered) {
        [self finish];
    } else if (eventCode == NSStreamEventErrorOccurred) {
        NSError *e = [_inputStream streamError];
        if (!e) e = [NSError errorWithDomain:@"iPad1FTPDownloader" code:2003
                                    userInfo:[NSDictionary dictionaryWithObject:@"FTP klasör listeleme hatası."
                                                                         forKey:NSLocalizedDescriptionKey]];
        [self fail:e];
    }
}

- (NSArray *)parseListing:(NSData *)listingData {
    NSMutableArray *items = [NSMutableArray array];
    NSString *text = [[[NSString alloc] initWithData:listingData encoding:NSUTF8StringEncoding] autorelease];
    if (!text) text = [[[NSString alloc] initWithData:listingData encoding:NSISOLatin1StringEncoding] autorelease];
    if (!text) return items;

    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *rawLine in lines) {
        NSString *line = [rawLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line length] == 0) continue;

        BOOL isDirectory = NO;
        NSString *name = nil;
        NSString *size = @"";

        if ([line length] >= 10 && ([line characterAtIndex:0] == 'd' || [line characterAtIndex:0] == '-')) {
            isDirectory = ([line characterAtIndex:0] == 'd');

            NSArray *parts = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSMutableArray *clean = [NSMutableArray array];
            for (NSString *p in parts) if ([p length] > 0) [clean addObject:p];

            if ([clean count] >= 9) {
                size = [clean objectAtIndex:4];
                NSRange r = [line rangeOfString:[clean objectAtIndex:8]];
                if (r.location != NSNotFound) name = [line substringFromIndex:r.location];
            }
        }

        if (!name || [name length] == 0) {
            name = line;
            size = @"";
        }

        if ([name isEqualToString:@"."] || [name isEqualToString:@".."]) continue;

        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                              name, @"name",
                              [NSNumber numberWithBool:isDirectory], @"isDirectory",
                              size, @"size", nil];
        [items addObject:item];
    }
    return items;
}

- (void)finish {
    if (_finished) return;
    _finished = YES;

    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [_inputStream release]; _inputStream = nil;

    NSArray *items = [self parseListing:_data];
    if ([_delegate respondsToSelector:@selector(ftpBrowser:didFinishWithItems:path:)])
        [_delegate ftpBrowser:self didFinishWithItems:items path:_path];
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
    if ([_delegate respondsToSelector:@selector(ftpBrowser:didFailWithError:)])
        [_delegate ftpBrowser:self didFailWithError:error];
}

- (void)cancel {
    if (_inputStream) {
        [_inputStream close];
        [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream setDelegate:nil];
        [_inputStream release]; _inputStream = nil;
    }
    _finished = YES;
}
@end
