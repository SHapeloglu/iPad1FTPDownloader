#import "WiFiReceiveServer.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <ifaddrs.h>

#define IP1_DOWNLOADS @"/var/mobile/Media/iPad1Files/Downloads"
#define IP1_HEADER_LIMIT 32768

@interface WiFiReceiveServer ()
- (void)serverLoop;
@end

@implementation WiFiReceiveServer
@synthesize delegate=_delegate;
- (BOOL)running { return _running; }
- (NSInteger)port { return _port; }
- (NSString *)token { return _token; }

- (id)init {
    self=[super init];
    if(self){ _listenFD=-1; _port=8080; }
    return self;
}

- (BOOL)ensureDownloads {
    BOOL d=NO;
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:IP1_DOWNLOADS isDirectory:&d]) return d;
    return [fm createDirectoryAtPath:IP1_DOWNLOADS withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString *)wifiAddress {
    struct ifaddrs *ifs=NULL;
    if(getifaddrs(&ifs)!=0) return nil;
    NSString *result=nil;
    for(struct ifaddrs *p=ifs;p;p=p->ifa_next){
        if(!p->ifa_addr || p->ifa_addr->sa_family!=AF_INET) continue;
        if(strcmp(p->ifa_name,"en0")!=0) continue;
        char buf[INET_ADDRSTRLEN];
        struct sockaddr_in *sin=(struct sockaddr_in *)p->ifa_addr;
        if(inet_ntop(AF_INET,&sin->sin_addr,buf,sizeof(buf))){ result=[NSString stringWithUTF8String:buf]; break; }
    }
    freeifaddrs(ifs);
    return result;
}

- (NSString *)localURL {
    NSString *ip=[self wifiAddress];
    if(![ip length]) return nil;
    return [NSString stringWithFormat:@"http://%@:%ld/?token=%@",ip,(long)_port,_token?:@""];
}

- (BOOL)start {
    if(_running) return YES;
    if(![self ensureDownloads]) return NO;
    [_token release];
    _token=[[NSString stringWithFormat:@"%06u",(unsigned)(arc4random()%1000000)] copy];
    _listenFD=socket(AF_INET,SOCK_STREAM,0);
    if(_listenFD<0) return NO;
    int yes=1; setsockopt(_listenFD,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes));
    struct sockaddr_in addr; memset(&addr,0,sizeof(addr));
    addr.sin_family=AF_INET; addr.sin_addr.s_addr=htonl(INADDR_ANY); addr.sin_port=htons((uint16_t)_port);
    if(bind(_listenFD,(struct sockaddr *)&addr,sizeof(addr))<0 || listen(_listenFD,2)<0){ close(_listenFD); _listenFD=-1; return NO; }
    _running=YES;
    _serverThread=[[NSThread alloc] initWithTarget:self selector:@selector(serverLoop) object:nil];
    [_serverThread start];
    NSString *url=[self localURL];
    if([_delegate respondsToSelector:@selector(wifiReceiveServer:didStartWithURL:)]) [_delegate wifiReceiveServer:self didStartWithURL:url?:@"Wi-Fi adresi bulunamadı"];
    return YES;
}

- (void)stop {
    _running=NO;
    if(_listenFD>=0){ shutdown(_listenFD,SHUT_RDWR); close(_listenFD); _listenFD=-1; }
}

- (void)sendString:(NSString *)s fd:(int)fd {
    NSData *d=[s dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *p=[d bytes]; NSInteger left=[d length];
    while(left>0){ ssize_t n=send(fd,p,left,0); if(n<=0) break; p+=n; left-=n; }
}

- (NSString *)headerValue:(NSString *)key headers:(NSString *)headers {
    NSArray *lines=[headers componentsSeparatedByString:@"\r\n"];
    NSString *prefix=[[key stringByAppendingString:@":"] lowercaseString];
    for(NSString *line in lines){
        if([[line lowercaseString] hasPrefix:prefix]) return [[line substringFromIndex:[prefix length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return nil;
}

- (NSString *)safeName:(NSString *)name {
    name=[[name lastPathComponent] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    if(![name length] || [name isEqualToString:@"."] || [name isEqualToString:@".."]) name=@"upload.bin";
    return name;
}

- (NSString *)uniquePath:(NSString *)name {
    NSFileManager *fm=[NSFileManager defaultManager];
    NSString *candidate=[IP1_DOWNLOADS stringByAppendingPathComponent:name];
    if(![fm fileExistsAtPath:candidate] && ![fm fileExistsAtPath:[candidate stringByAppendingString:@".part"]]) return candidate;
    NSString *ext=[name pathExtension], *base=[name stringByDeletingPathExtension];
    for(NSInteger i=1;i<10000;i++){
        NSString *n=[ext length]?[NSString stringWithFormat:@"%@ (%ld).%@",base,(long)i,ext]:[NSString stringWithFormat:@"%@ (%ld)",base,(long)i];
        candidate=[IP1_DOWNLOADS stringByAppendingPathComponent:n];
        if(![fm fileExistsAtPath:candidate] && ![fm fileExistsAtPath:[candidate stringByAppendingString:@".part"]]) return candidate;
    }
    return [IP1_DOWNLOADS stringByAppendingPathComponent:@"upload.bin"];
}

- (void)handleClient:(int)fd {
    NSMutableData *headerData=[NSMutableData data];
    uint8_t buf[4096];
    NSRange sep=NSMakeRange(NSNotFound,0);
    while([headerData length]<IP1_HEADER_LIMIT){
        ssize_t n=recv(fd,buf,sizeof(buf),0); if(n<=0) return;
        [headerData appendBytes:buf length:(NSUInteger)n];
        sep=[headerData rangeOfData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0,[headerData length])];
        if(sep.location!=NSNotFound) break;
    }
    if(sep.location==NSNotFound){ [self sendString:@"HTTP/1.1 431 Request Header Fields Too Large\r\nConnection: close\r\n\r\n" fd:fd]; return; }
    NSUInteger bodyOffset=sep.location+sep.length;
    NSData *head=[headerData subdataWithRange:NSMakeRange(0,sep.location)];
    NSString *headers=[[[NSString alloc] initWithData:head encoding:NSUTF8StringEncoding] autorelease];
    NSArray *lines=[headers componentsSeparatedByString:@"\r\n"];
    NSString *request=[lines count]?[lines objectAtIndex:0]:@"";

    if([request hasPrefix:@"GET "]){
        NSString *html=[NSString stringWithFormat:@"<!doctype html><html><head><meta charset='utf-8'><title>iPad1 Wi-Fi Receive</title></head><body><h2>iPad1 Wi-Fi Receive</h2><p>Dosya seçip Gönder'e basın.</p><input id='f' type='file'><button onclick='up()'>Gönder</button><pre id='s'></pre><script>function up(){var f=document.getElementById('f').files[0];if(!f){return;}var x=new XMLHttpRequest();x.open('PUT','/upload/'+encodeURIComponent(f.name)+'?token=%@');x.upload.onprogress=function(e){if(e.lengthComputable)s.textContent=Math.round(e.loaded*100/e.total)+'%%';};x.onload=function(){s.textContent=x.responseText;};x.send(f);}</script></body></html>",_token];
        NSData *d=[html dataUsingEncoding:NSUTF8StringEncoding];
        [self sendString:[NSString stringWithFormat:@"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %lu\r\nConnection: close\r\n\r\n",(unsigned long)[d length]] fd:fd];
        send(fd,[d bytes],[d length],0);
        return;
    }

    if(![request hasPrefix:@"PUT /upload/"]){ [self sendString:@"HTTP/1.1 405 Method Not Allowed\r\nConnection: close\r\n\r\n" fd:fd]; return; }
    NSRange q=[request rangeOfString:@"?token="];
    NSRange http=[request rangeOfString:@" HTTP/"];
    if(q.location==NSNotFound || http.location==NSNotFound || http.location<=q.location){ [self sendString:@"HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n" fd:fd]; return; }
    NSString *tok=[request substringWithRange:NSMakeRange(q.location+7,http.location-(q.location+7))];
    if(![tok isEqualToString:_token]){ [self sendString:@"HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n" fd:fd]; return; }
    NSString *raw=[request substringWithRange:NSMakeRange(12,q.location-12)];
    NSString *name=[[raw stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
    name=[self safeName:name];
    unsigned long long total=(unsigned long long)[[self headerValue:@"Content-Length" headers:headers] longLongValue];
    if(total==0){ [self sendString:@"HTTP/1.1 411 Length Required\r\nConnection: close\r\n\r\n" fd:fd]; return; }

    NSString *final=[self uniquePath:name]; NSString *part=[final stringByAppendingString:@".part"];
    [[NSFileManager defaultManager] createFileAtPath:part contents:nil attributes:nil];
    NSFileHandle *fh=[NSFileHandle fileHandleForWritingAtPath:part];
    if(!fh){ [self sendString:@"HTTP/1.1 500 Internal Server Error\r\nConnection: close\r\n\r\n" fd:fd]; return; }
    unsigned long long received=0;
    if([headerData length]>bodyOffset){
        NSData *initial=[headerData subdataWithRange:NSMakeRange(bodyOffset,[headerData length]-bodyOffset)];
        NSUInteger use=(NSUInteger)MIN((unsigned long long)[initial length],total);
        [fh writeData:[initial subdataWithRange:NSMakeRange(0,use)]]; received+=use;
    }
    while(received<total && _running){
        size_t want=(size_t)MIN((unsigned long long)sizeof(buf),total-received);
        ssize_t n=recv(fd,buf,want,0); if(n<=0) break;
        [fh writeData:[NSData dataWithBytes:buf length:(NSUInteger)n]]; received+=(unsigned long long)n;
        if([_delegate respondsToSelector:@selector(wifiReceiveServer:didReceiveBytes:totalBytes:filename:)]) [_delegate wifiReceiveServer:self didReceiveBytes:received totalBytes:total filename:name];
    }
    [fh synchronizeFile]; [fh closeFile];
    if(received==total){
        NSError *e=nil;
        if([[NSFileManager defaultManager] moveItemAtPath:part toPath:final error:&e]){
            [self sendString:@"HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nConnection: close\r\n\r\nAktarım tamamlandı." fd:fd];
            if([_delegate respondsToSelector:@selector(wifiReceiveServer:didFinishPath:bytes:)]) [_delegate wifiReceiveServer:self didFinishPath:final bytes:received];
        } else {
            if([_delegate respondsToSelector:@selector(wifiReceiveServer:didFailWithMessage:)]) [_delegate wifiReceiveServer:self didFailWithMessage:[e localizedDescription]];
        }
    } else {
        if([_delegate respondsToSelector:@selector(wifiReceiveServer:didFailWithMessage:)]) [_delegate wifiReceiveServer:self didFailWithMessage:@"Wi-Fi aktarımı yarıda kesildi. .part dosyası korundu."];
    }
}

- (void)serverLoop {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    while(_running){
        struct sockaddr_in c; socklen_t l=sizeof(c);
        int fd=accept(_listenFD,(struct sockaddr *)&c,&l);
        if(fd<0){ if(!_running) break; continue; }
        NSAutoreleasePool *inner=[[NSAutoreleasePool alloc] init];
        [self handleClient:fd];
        shutdown(fd,SHUT_RDWR); close(fd);
        [inner drain];
    }
    [pool drain];
}

- (void)dealloc { [self stop]; [_serverThread release]; [_token release]; [super dealloc]; }
@end
