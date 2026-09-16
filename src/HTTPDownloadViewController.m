#import "HTTPDownloadViewController.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation HTTPDownloadViewController

- (UITextField *)field:(CGRect)frame placeholder:(NSString *)placeholder {
    UITextField *f=[[[UITextField alloc] initWithFrame:frame] autorelease];
    f.borderStyle=UITextBorderStyleRoundedRect;
    f.placeholder=placeholder;
    f.autocapitalizationType=UITextAutocapitalizationTypeNone;
    f.autocorrectionType=UITextAutocorrectionTypeNo;
    f.keyboardType=UIKeyboardTypeURL;
    f.delegate=self;
    return f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"HTTP / HTTPS";
    self.view.backgroundColor=[UIColor colorWithWhite:.95 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(24,24,720,34)] autorelease];
    title.text=@"HTTP / HTTPS İndirme";
    title.font=[UIFont boldSystemFontOfSize:24];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    _urlField=[[self field:CGRectMake(24,74,720,38) placeholder:@"https://... veya http://..."] retain];
    [self.view addSubview:_urlField];

    _startButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _startButton.frame=CGRectMake(24,130,150,42);
    [_startButton setTitle:@"İndir" forState:0];
    [_startButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];

    _cancelButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _cancelButton.frame=CGRectMake(190,130,150,42);
    [_cancelButton setTitle:@"İptal" forState:0];
    [_cancelButton addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.enabled=NO;
    [self.view addSubview:_cancelButton];

    _progress=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progress.frame=CGRectMake(24,194,720,12);
    [self.view addSubview:_progress];

    _status=[[UILabel alloc] initWithFrame:CGRectMake(24,218,720,72)];
    _status.backgroundColor=[UIColor clearColor];
    _status.numberOfLines=3;
    _status.text=@"Hazır";
    [self.view addSubview:_status];

    _speed=[[UILabel alloc] initWithFrame:CGRectMake(24,292,720,30)];
    _speed.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_speed];

    UILabel *note=[[[UILabel alloc] initWithFrame:CGRectMake(24,350,720,100)] autorelease];
    note.backgroundColor=[UIColor clearColor];
    note.numberOfLines=5;
    note.font=[UIFont systemFontOfSize:13];
    note.text=@"Dosya doğrudan /var/mobile/Media/iPad1Files/Downloads/ içine yazılır. Yerel dosya yönetimi iPad1Files'a aittir. Büyük dosya belleğe alınmaz; diske stream edilir.";
    [self.view addSubview:note];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self startDownload];
    return YES;
}

- (void)startDownload {
    NSString *s=[_urlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *u=[NSURL URLWithString:s];
    NSString *scheme=[[u scheme] lowercaseString];
    if(!u || !([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])){
        _status.text=@"Geçerli bir HTTP/HTTPS adresi girin.";
        return;
    }
    [_task cancel]; [_task release];
    _task=[[HTTPDownloadTask alloc] init];
    _task.delegate=self;
    _progress.progress=0;
    _startButton.enabled=NO;
    _cancelButton.enabled=YES;
    _status.text=@"Bağlanıyor...";
    _speed.text=@"";
    [_task downloadURL:u];
}

- (void)cancelDownload {
    [_task cancel];
    _startButton.enabled=YES;
    _cancelButton.enabled=NO;
    _status.text=@"İndirme iptal edildi. Yarım .part dosyası daha sonra resume için korunur.";
}

- (NSString *)sizeText:(unsigned long long)b {
    double v=b;
    if(b>=1073741824ULL)return[NSString stringWithFormat:@"%.2f GB",v/1073741824.0];
    if(b>=1048576ULL)return[NSString stringWithFormat:@"%.2f MB",v/1048576.0];
    if(b>=1024ULL)return[NSString stringWithFormat:@"%.1f KB",v/1024.0];
    return[NSString stringWithFormat:@"%llu B",b];
}

- (NSString *)speedText:(double)b {
    if(b>=1048576)return[NSString stringWithFormat:@"%.2f MB/s",b/1048576.0];
    if(b>=1024)return[NSString stringWithFormat:@"%.1f KB/s",b/1024.0];
    return[NSString stringWithFormat:@"%.0f B/s",b];
}

- (void)httpDownloadTaskDidStart:(HTTPDownloadTask *)task destination:(NSString *)destination expectedBytes:(long long)expectedBytes {
    (void)task;
    _status.text=[NSString stringWithFormat:@"İndiriliyor: %@",[destination lastPathComponent]];
    if(expectedBytes>0) _speed.text=[NSString stringWithFormat:@"Boyut: %@",[self sizeText:(unsigned long long)expectedBytes]];
}

- (void)httpDownloadTask:(HTTPDownloadTask *)task didReceiveBytes:(unsigned long long)received totalBytes:(long long)total bytesPerSecond:(double)bytesPerSecond {
    (void)task;
    if(total>0){
        float p=(float)((double)received/(double)total); if(p>1)p=1;
        _progress.progress=p;
        _status.text=[NSString stringWithFormat:@"%d%% • %@ / %@",(int)(p*100),[self sizeText:received],[self sizeText:(unsigned long long)total]];
    } else _status.text=[NSString stringWithFormat:@"%@ indirildi",[self sizeText:received]];
    _speed.text=[self speedText:bytesPerSecond];
}

- (NSString *)encodedPath:(NSString *)path {
    CFStringRef e=CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)path,NULL,CFSTR(":/?@&=+$,#[]!()*'\""),kCFStringEncodingUTF8);
    return [(NSString *)e autorelease];
}

- (void)openScheme:(NSString *)scheme action:(NSString *)action path:(NSString *)path {
    NSString *s=[NSString stringWithFormat:@"%@://%@?path=%@",scheme,action,[self encodedPath:path]];
    NSURL *u=[NSURL URLWithString:s];
    if(u && [[UIApplication sharedApplication] canOpenURL:u]) [[UIApplication sharedApplication] openURL:u];
    else _status.text=[NSString stringWithFormat:@"%@ uygulaması bulunamadı.",scheme];
}

- (void)httpDownloadTaskDidFinish:(HTTPDownloadTask *)task destination:(NSString *)destination bytes:(unsigned long long)bytes {
    (void)task;
    [_completedPath release]; _completedPath=[destination copy];
    _progress.progress=1;
    _startButton.enabled=YES; _cancelButton.enabled=NO;
    _status.text=[NSString stringWithFormat:@"Tamamlandı: %@",[destination lastPathComponent]];
    _speed.text=[self sizeText:bytes];
    NSString *ext=[[destination pathExtension] lowercaseString];
    NSMutableArray *actions=[NSMutableArray array];
    if([ext isEqualToString:@"pdf"]) [actions addObject:@"PDFReader ile Aç"];
    else if([ext isEqualToString:@"mkv"]||[ext isEqualToString:@"mp4"]||[ext isEqualToString:@"mov"]||[ext isEqualToString:@"m4v"]||[ext isEqualToString:@"avi"]) [actions addObject:@"iPad1Player ile Aç"];
    [actions addObject:@"Dosyalarda Göster"];
    UIActionSheet *sheet=[[[UIActionSheet alloc] initWithTitle:@"İndirme tamamlandı" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    for(NSString *a in actions) [sheet addButtonWithTitle:a];
    NSInteger c=[sheet addButtonWithTitle:@"Tamam"]; sheet.cancelButtonIndex=c;
    [sheet showInView:self.view];
}

- (void)httpDownloadTask:(HTTPDownloadTask *)task didFailWithError:(NSError *)error {
    (void)task;
    _startButton.enabled=YES; _cancelButton.enabled=NO;
    _status.text=[NSString stringWithFormat:@"İndirme hatası: %@",[error localizedDescription]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==actionSheet.cancelButtonIndex || !_completedPath) return;
    NSString *label=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([label hasPrefix:@"PDFReader"]) [self openScheme:@"ipad1pdf" action:@"open" path:_completedPath];
    else if([label hasPrefix:@"iPad1Player"]) [self openScheme:@"ipad1player" action:@"open" path:_completedPath];
    else if([label isEqualToString:@"Dosyalarda Göster"]) [self openScheme:@"ipad1files" action:@"show" path:_completedPath];
}

- (void)dealloc {
    _task.delegate=nil; [_task cancel]; [_task release];
    [_completedPath release]; [_urlField release]; [_startButton release]; [_cancelButton release]; [_progress release]; [_status release]; [_speed release];
    [super dealloc];
}
@end
