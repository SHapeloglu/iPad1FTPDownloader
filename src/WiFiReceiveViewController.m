#import "WiFiReceiveViewController.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation WiFiReceiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Wi-Fi Al";
    self.view.backgroundColor=[UIColor colorWithWhite:.95 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(24,24,720,36)] autorelease];
    title.text=@"Windows → iPad Wi-Fi Dosya Aktarımı";
    title.font=[UIFont boldSystemFontOfSize:22];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    _toggleButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _toggleButton.frame=CGRectMake(24,76,170,42);
    [_toggleButton setTitle:@"Alıcıyı Başlat" forState:0];
    [_toggleButton addTarget:self action:@selector(toggleServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toggleButton];

    _urlLabel=[[UILabel alloc] initWithFrame:CGRectMake(24,138,720,42)];
    _urlLabel.backgroundColor=[UIColor clearColor];
    _urlLabel.font=[UIFont boldSystemFontOfSize:16];
    _urlLabel.text=@"Adres: -";
    [self.view addSubview:_urlLabel];

    _tokenLabel=[[UILabel alloc] initWithFrame:CGRectMake(24,182,720,34)];
    _tokenLabel.backgroundColor=[UIColor clearColor];
    _tokenLabel.text=@"Kod: -";
    [self.view addSubview:_tokenLabel];

    _statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(24,226,720,60)];
    _statusLabel.backgroundColor=[UIColor clearColor];
    _statusLabel.numberOfLines=3;
    _statusLabel.text=@"Alıcı kapalı.";
    [self.view addSubview:_statusLabel];

    _progress=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progress.frame=CGRectMake(24,302,720,12);
    [self.view addSubview:_progress];

    _progressLabel=[[UILabel alloc] initWithFrame:CGRectMake(24,322,720,32)];
    _progressLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_progressLabel];

    UILabel *help=[[[UILabel alloc] initWithFrame:CGRectMake(24,380,720,150)] autorelease];
    help.backgroundColor=[UIColor clearColor];
    help.numberOfLines=7;
    help.font=[UIFont systemFontOfSize:14];
    help.text=@"1) iPad ve Windows aynı Wi-Fi ağında olsun.\n2) Alıcıyı Başlat'a dokunun.\n3) Windows tarayıcısında gösterilen adresi açın.\n4) Dosyayı seçip Gönder'e basın.\n\nDosya iPad1Files/Downloads alanına stream edilir. Klasör/dosya yönetimi iPad1Files'a aittir.";
    [self.view addSubview:help];

    _server=[[WiFiReceiveServer alloc] init];
    _server.delegate=self;
}

- (void)toggleServer {
    if(_server.running){
        [_server stop];
        [_toggleButton setTitle:@"Alıcıyı Başlat" forState:0];
        _urlLabel.text=@"Adres: -";
        _tokenLabel.text=@"Kod: -";
        _statusLabel.text=@"Alıcı kapalı.";
    } else {
        if([_server start]){
            [_toggleButton setTitle:@"Alıcıyı Durdur" forState:0];
        } else {
            _statusLabel.text=@"Wi-Fi alıcısı başlatılamadı. Port veya ağ erişimini kontrol edin.";
        }
    }
}

- (NSString *)sizeText:(unsigned long long)b {
    double v=b;
    if(b>=1073741824ULL)return[NSString stringWithFormat:@"%.2f GB",v/1073741824.0];
    if(b>=1048576ULL)return[NSString stringWithFormat:@"%.2f MB",v/1048576.0];
    if(b>=1024ULL)return[NSString stringWithFormat:@"%.1f KB",v/1024.0];
    return[NSString stringWithFormat:@"%llu B",b];
}

- (void)applyStart:(NSDictionary *)d {
    _urlLabel.text=[NSString stringWithFormat:@"Adres: %@",[d objectForKey:@"url"]];
    _tokenLabel.text=[NSString stringWithFormat:@"Kod: %@",[d objectForKey:@"token"]];
    _statusLabel.text=@"Hazır. Windows tarayıcısından dosya gönderebilirsiniz.";
}

- (void)wifiReceiveServer:(WiFiReceiveServer *)server didStartWithURL:(NSString *)url {
    NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:(url?:@"-"),@"url",(server.token?:@"-"),@"token",nil];
    [self performSelectorOnMainThread:@selector(applyStart:) withObject:d waitUntilDone:NO];
}

- (void)applyProgress:(NSDictionary *)d {
    unsigned long long r=[[d objectForKey:@"r"] unsignedLongLongValue];
    unsigned long long t=[[d objectForKey:@"t"] unsignedLongLongValue];
    NSString *n=[d objectForKey:@"n"];
    _progress.progress=t?(float)((double)r/(double)t):0;
    _progressLabel.text=[NSString stringWithFormat:@"%@ • %@ / %@",n,[self sizeText:r],[self sizeText:t]];
}

- (void)wifiReceiveServer:(WiFiReceiveServer *)server didReceiveBytes:(unsigned long long)received totalBytes:(unsigned long long)total filename:(NSString *)filename {
    (void)server;
    NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:received],@"r",[NSNumber numberWithUnsignedLongLong:total],@"t",(filename?:@""),@"n",nil];
    [self performSelectorOnMainThread:@selector(applyProgress:) withObject:d waitUntilDone:NO];
}

- (void)applyFinish:(NSDictionary *)d {
    NSString *p=[d objectForKey:@"p"];
    unsigned long long b=[[d objectForKey:@"b"] unsignedLongLongValue];
    [_completedPath release]; _completedPath=[p copy];
    _progress.progress=1;
    _statusLabel.text=[NSString stringWithFormat:@"Aktarım tamamlandı: %@",[p lastPathComponent]];
    _progressLabel.text=[self sizeText:b];
}

- (void)wifiReceiveServer:(WiFiReceiveServer *)server didFinishPath:(NSString *)path bytes:(unsigned long long)bytes {
    (void)server;
    NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:path,@"p",[NSNumber numberWithUnsignedLongLong:bytes],@"b",nil];
    [self performSelectorOnMainThread:@selector(applyFinish:) withObject:d waitUntilDone:NO];
}

- (void)applyError:(NSString *)s { _statusLabel.text=s; }
- (void)wifiReceiveServer:(WiFiReceiveServer *)server didFailWithMessage:(NSString *)message {
    (void)server;
    [self performSelectorOnMainThread:@selector(applyError:) withObject:(message?:@"Wi-Fi aktarım hatası") waitUntilDone:NO];
}

- (void)dealloc {
    _server.delegate=nil; [_server stop]; [_server release];
    [_urlLabel release]; [_tokenLabel release]; [_statusLabel release]; [_progressLabel release]; [_progress release]; [_toggleButton release]; [_completedPath release];
    [super dealloc];
}
@end
