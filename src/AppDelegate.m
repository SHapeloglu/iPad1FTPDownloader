#import "AppDelegate.h"
#import "FTPPathUtils.h"
#import <CoreFoundation/CoreFoundation.h>
#define SERVERS_KEY @"SavedFTPServersV12"
#define DOWNLOADS @"/var/mobile/Media/iPad1Files/Downloads"
@implementation AppDelegate
@synthesize window=_window;
- (UITextField*)field:(CGRect)f placeholder:(NSString*)p{UITextField*t=[[[UITextField alloc]initWithFrame:f]autorelease];t.borderStyle=UITextBorderStyleRoundedRect;t.placeholder=p;t.autocapitalizationType=UITextAutocapitalizationTypeNone;t.autocorrectionType=UITextAutocorrectionTypeNo;t.delegate=self;return t;}
- (BOOL)application:(UIApplication*)app didFinishLaunchingWithOptions:(NSDictionary*)opts{
 _window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];UIViewController*vc=[[[UIViewController alloc]init]autorelease];vc.view.backgroundColor=[UIColor colorWithWhite:.94 alpha:1];
 UILabel*title=[[[UILabel alloc]initWithFrame:CGRectMake(20,14,728,32)]autorelease];title.text=@"iPad 1 FTP Client v1.3";title.font=[UIFont boldSystemFontOfSize:22];title.textAlignment=UITextAlignmentCenter;title.backgroundColor=[UIColor clearColor];[vc.view addSubview:title];
 CGFloat y=52,h=34;_hostField=[[self field:CGRectMake(22,y,420,h) placeholder:@"FTP Sunucusu / IP"]retain];[vc.view addSubview:_hostField];_portField=[[self field:CGRectMake(448,y,74,h) placeholder:@"Port"]retain];_portField.text=@"21";[vc.view addSubview:_portField];
 _serversButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_serversButton.frame=CGRectMake(528,y,102,h);[_serversButton setTitle:@"Sunucular" forState:0];[_serversButton addTarget:self action:@selector(showServers) forControlEvents:UIControlEventTouchUpInside];[vc.view addSubview:_serversButton];
 _saveButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_saveButton.frame=CGRectMake(636,y,108,h);[_saveButton setTitle:@"Kaydet" forState:0];[_saveButton addTarget:self action:@selector(saveServer) forControlEvents:UIControlEventTouchUpInside];[vc.view addSubview:_saveButton];
 y+=40;_userField=[[self field:CGRectMake(22,y,350,h) placeholder:@"Kullanıcı adı"]retain];[vc.view addSubview:_userField];_passField=[[self field:CGRectMake(378,y,366,h) placeholder:@"Şifre"]retain];_passField.secureTextEntry=YES;[vc.view addSubview:_passField];
 y+=40;_pathField=[[self field:CGRectMake(22,y,390,h) placeholder:@"Klasör yolu"]retain];_pathField.text=@"/";[vc.view addSubview:_pathField];_connectButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_connectButton.frame=CGRectMake(418,y,120,h);[_connectButton setTitle:@"Bağlan / Listele" forState:0];[_connectButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];[vc.view addSubview:_connectButton];
 _newFolderButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_newFolderButton.frame=CGRectMake(544,y,92,h);[_newFolderButton setTitle:@"+ Klasör" forState:0];[_newFolderButton addTarget:self action:@selector(newFolder) forControlEvents:UIControlEventTouchUpInside];[vc.view addSubview:_newFolderButton];_uploadButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_uploadButton.frame=CGRectMake(642,y,102,h);[_uploadButton setTitle:@"Yükle" forState:0];[_uploadButton addTarget:self action:@selector(showUpload) forControlEvents:UIControlEventTouchUpInside];[vc.view addSubview:_uploadButton];
 y+=40;_upButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];_upButton.frame=CGRectMake(22,y,105,30);[_upButton setTitle:@"← Üst Klasör" forState:0];[_upButton addTarget:self action:@selector(up) forControlEvents:UIControlEventTouchUpInside];_upButton.enabled=NO;[vc.view addSubview:_upButton];_statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(135,y,609,30)];_statusLabel.backgroundColor=[UIColor clearColor];_statusLabel.font=[UIFont systemFontOfSize:13];_statusLabel.text=@"Hazır";[vc.view addSubview:_statusLabel];
 y+=34;_progressView=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];_progressView.frame=CGRectMake(22,y+7,722,10);[vc.view addSubview:_progressView];y+=21;_bytesLabel=[[UILabel alloc]initWithFrame:CGRectMake(22,y,722,24)];_bytesLabel.backgroundColor=[UIColor clearColor];_bytesLabel.textAlignment=UITextAlignmentCenter;_bytesLabel.font=[UIFont systemFontOfSize:12];_bytesLabel.text=@"Dosyaya dokun: indir • mavi oka dokun: yeniden adlandır • sola kaydır: sil";[vc.view addSubview:_bytesLabel];
 y+=27;_tableView=[[UITableView alloc]initWithFrame:CGRectMake(22,y,722,760) style:UITableViewStylePlain];_tableView.dataSource=self;_tableView.delegate=self;[vc.view addSubview:_tableView];
 _browser=[[FTPBrowser alloc]init];_browser.delegate=self;_downloader=[[FTPDownloader alloc]init];_downloader.delegate=self;_uploader=[[FTPUploader alloc]init];_uploader.delegate=self;_commandClient=[[FTPCommandClient alloc]init];_commandClient.delegate=self;_items=[[NSArray alloc]init];_currentPath=[@"/" copy];[self ensureDownloadsDirectory];_window.rootViewController=vc;[_window makeKeyAndVisible];return YES;}
- (void)dismiss{[_hostField resignFirstResponder];[_portField resignFirstResponder];[_userField resignFirstResponder];[_passField resignFirstResponder];[_pathField resignFirstResponder];}
- (BOOL)textFieldShouldReturn:(UITextField*)t{[t resignFirstResponder];return YES;}
- (NSString*)sizeText:(unsigned long long)b{double v=b;if(b>=1073741824ULL)return[NSString stringWithFormat:@"%.2f GB",v/1073741824.0];if(b>=1048576ULL)return[NSString stringWithFormat:@"%.2f MB",v/1048576.0];if(b>=1024ULL)return[NSString stringWithFormat:@"%.1f KB",v/1024.0];return[NSString stringWithFormat:@"%llu B",b];}
- (NSString*)speedText:(double)b{if(b>=1048576)return[NSString stringWithFormat:@"%.2f MB/s",b/1048576.0];if(b>=1024)return[NSString stringWithFormat:@"%.1f KB/s",b/1024.0];return[NSString stringWithFormat:@"%.0f B/s",b];}
- (BOOL)ensureDownloadsDirectory {
 BOOL isDirectory=NO;NSFileManager*fm=[NSFileManager defaultManager];
 if([fm fileExistsAtPath:DOWNLOADS isDirectory:&isDirectory])return isDirectory;
 NSError*error=nil;BOOL ok=[fm createDirectoryAtPath:DOWNLOADS withIntermediateDirectories:YES attributes:nil error:&error];
 if(!ok&&_statusLabel)_statusLabel.text=[NSString stringWithFormat:@"Downloads klasörü oluşturulamadı: %@",[error localizedDescription]];
 return ok;
}
- (void)capture{[_host release];[_username release];[_password release];_host=[[_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]copy];_username=[_userField.text copy];_password=[_passField.text copy];_port=[_portField.text integerValue];if(_port<=0||_port>65535)_port=21;}
- (NSString*)normalizedDirectoryPath:(NSString*)path { return [FTPPathUtils normalizedRemoteDirectoryPath:path]; }
- (NSString*)remotePathForName:(NSString*)n { return [FTPPathUtils remotePathForName:n inDirectory:_currentPath]; }
- (NSString*)remoteDirectoryPathForName:(NSString*)n { return [FTPPathUtils normalizedRemoteDirectoryPath:[self remotePathForName:n]]; }
- (void)setCurrentDirectoryPath:(NSString*)path {
 NSString*p=[FTPPathUtils normalizedRemoteDirectoryPath:path];
 [_currentPath release];_currentPath=[p copy];_pathField.text=_currentPath;_upButton.enabled=![_currentPath isEqualToString:@"/"];
}
- (void)refresh{if([_host length]){[self setCurrentDirectoryPath:_currentPath];[_browser listHost:_host port:_port username:_username password:_password path:_currentPath];}}
- (void)connect{[self dismiss];[self capture];if(![_host length]){_statusLabel.text=@"Sunucu gerekli.";return;}[self setCurrentDirectoryPath:_pathField.text];[self refresh];}
- (void)up{
 if([_currentPath isEqualToString:@"/"])return;
 NSString*p=_currentPath;
 while([p length]>1&&[p hasSuffix:@"/"])p=[p substringToIndex:[p length]-1];
 NSRange slash=[p rangeOfString:@"/" options:NSBackwardsSearch];
 NSString*parent=(slash.location==NSNotFound||slash.location==0)?@"/":[p substringToIndex:slash.location+1];
 [self setCurrentDirectoryPath:parent];
 [self refresh];
}
- (NSArray*)saved{return [[NSUserDefaults standardUserDefaults]objectForKey:SERVERS_KEY]?:[NSArray array];}
- (void)saveServer{[self capture];if(![_host length])return;[_saveAlert release];_saveAlert=[[UIAlertView alloc]initWithTitle:@"Sunucuyu Kaydet" message:@"Profil adı" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Kaydet",nil];_saveAlert.alertViewStyle=UIAlertViewStylePlainTextInput;[[_saveAlert textFieldAtIndex:0]setText:_host];[_saveAlert show];}
- (void)showServers{NSArray*a=[self saved];if(![a count]){UIAlertView*v=[[[UIAlertView alloc]initWithTitle:@"Kayıtlı sunucu yok" message:@"Bağlantıyı girip Kaydet'e dokunun." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil]autorelease];[v show];return;}[_serversSheet release];_serversSheet=[[UIActionSheet alloc]initWithTitle:@"Kayıtlı Sunucular" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];for(NSDictionary*d in a)[_serversSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ — %@",[d objectForKey:@"name"],[d objectForKey:@"host"]]];NSInteger c=[_serversSheet addButtonWithTitle:@"İptal"];_serversSheet.cancelButtonIndex=c;[_serversSheet showInView:_window];}
- (NSArray*)localFiles{NSArray*a=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:DOWNLOADS error:nil];NSMutableArray*r=[NSMutableArray array];for(NSString*n in a){BOOL d=NO;NSString*f=[DOWNLOADS stringByAppendingPathComponent:n];if([[NSFileManager defaultManager]fileExistsAtPath:f isDirectory:&d]&&!d)[r addObject:n];}return r;}
- (void)showUpload{[self capture];NSArray*a=[self localFiles];if(![a count]){_statusLabel.text=@"Downloads klasöründe yüklenecek dosya yok.";return;}[_uploadSheet release];_uploadSheet=[[UIActionSheet alloc]initWithTitle:@"Yüklenecek Dosya" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];for(NSString*n in a)[_uploadSheet addButtonWithTitle:n];NSInteger c=[_uploadSheet addButtonWithTitle:@"İptal"];_uploadSheet.cancelButtonIndex=c;[_uploadSheet showInView:_window];}
- (void)newFolder{[self capture];if(![_host length])return;[_folderAlert release];_folderAlert=[[UIAlertView alloc]initWithTitle:@"Yeni Klasör" message:@"Klasör adı" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Oluştur",nil];_folderAlert.alertViewStyle=UIAlertViewStylePlainTextInput;[_folderAlert show];}
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s{return[_items count];}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i{static NSString*c=@"v12";UITableViewCell*cell=[t dequeueReusableCellWithIdentifier:c];if(!cell)cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:c]autorelease];NSDictionary*d=[_items objectAtIndex:i.row];BOOL dir=[[d objectForKey:@"isDirectory"]boolValue];cell.textLabel.text=[d objectForKey:@"name"];cell.detailTextLabel.text=dir?@"Klasör":[self sizeText:(unsigned long long)[[d objectForKey:@"size"]longLongValue]];cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;return cell;}
- (void)tableView:(UITableView*)t didSelectRowAtIndexPath:(NSIndexPath*)i{[t deselectRowAtIndexPath:i animated:YES];NSDictionary*d=[_items objectAtIndex:i.row];NSString*n=[d objectForKey:@"name"];if([[d objectForKey:@"isDirectory"]boolValue]){[self setCurrentDirectoryPath:[self remoteDirectoryPathForName:n]];[self refresh];return;}NSString*r=[self remotePathForName:n];if(![self ensureDownloadsDirectory]){_statusLabel.text=@"İndirme klasörü hazırlanamadı.";return;}_downloadExpected=(unsigned long long)[[d objectForKey:@"size"]longLongValue];_downloadStart=[NSDate timeIntervalSinceReferenceDate];_progressView.progress=0;[_downloader downloadHost:_host port:_port username:_username password:_password remotePath:r destinationPath:[DOWNLOADS stringByAppendingPathComponent:[n lastPathComponent]]];}
- (void)tableView:(UITableView*)t accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)i{[_pendingIndexPath release];[_completedDownloadPath release];_pendingIndexPath=[i retain];NSDictionary*d=[_items objectAtIndex:i.row];[_renameAlert release];_renameAlert=[[UIAlertView alloc]initWithTitle:@"Yeniden Adlandır" message:@"Yeni ad" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Değiştir",nil];_renameAlert.alertViewStyle=UIAlertViewStylePlainTextInput;[[_renameAlert textFieldAtIndex:0]setText:[d objectForKey:@"name"]];[_renameAlert show];}
- (BOOL)tableView:(UITableView*)t canEditRowAtIndexPath:(NSIndexPath*)i{return YES;}
- (void)tableView:(UITableView*)t commitEditingStyle:(UITableViewCellEditingStyle)e forRowAtIndexPath:(NSIndexPath*)i{if(e!=UITableViewCellEditingStyleDelete)return;NSDictionary*d=[_items objectAtIndex:i.row];FTPCommandAction a=[[d objectForKey:@"isDirectory"]boolValue]?FTPCommandActionDeleteDirectory:FTPCommandActionDeleteFile;[_commandClient performAction:a host:_host port:_port username:_username password:_password path1:[self remotePathForName:[d objectForKey:@"name"]] path2:nil];_statusLabel.text=@"Siliniyor...";}
- (void)actionSheet:(UIActionSheet*)s clickedButtonAtIndex:(NSInteger)b{if(s==_serversSheet){NSArray*a=[self saved];if(b<(NSInteger)[a count]){NSDictionary*d=[a objectAtIndex:b];_hostField.text=[d objectForKey:@"host"];_portField.text=[NSString stringWithFormat:@"%@",[d objectForKey:@"port"]];_userField.text=[d objectForKey:@"username"];_passField.text=[d objectForKey:@"password"];_pathField.text=[d objectForKey:@"path"];[self connect];}}else if(s==_uploadSheet){NSArray*a=[self localFiles];if(b<(NSInteger)[a count]){NSString*n=[a objectAtIndex:b];_progressView.progress=0;[_uploader uploadFile:[DOWNLOADS stringByAppendingPathComponent:n] host:_host port:_port username:_username password:_password remotePath:[self remotePathForName:n]];}}else if(s==_completionSheet&&b!=s.cancelButtonIndex){BOOL isPDF=[[[(_completedDownloadPath?:@"") pathExtension] lowercaseString]isEqualToString:@"pdf"];if(isPDF){if(b==0)[self openCompletedPathInPDFReader];else if(b==1)[self showCompletedPathInFiles];}else if(b==0)[self showCompletedPathInFiles];}}
- (void)alertView:(UIAlertView*)a clickedButtonAtIndex:(NSInteger)b{if(b==a.cancelButtonIndex)return;if(a==_saveAlert){NSString*n=[[a textFieldAtIndex:0]text];NSMutableArray*m=[NSMutableArray arrayWithArray:[self saved]];[m addObject:[NSDictionary dictionaryWithObjectsAndKeys:([n length]?n:_host),@"name",_host,@"host",[NSNumber numberWithInteger:_port],@"port",(_username?:@""),@"username",(_password?:@""),@"password",(_currentPath?:@"/"),@"path",nil]];[[NSUserDefaults standardUserDefaults]setObject:m forKey:SERVERS_KEY];[[NSUserDefaults standardUserDefaults]synchronize];_statusLabel.text=@"Sunucu kaydedildi.";}else if(a==_folderAlert){NSString*n=[[a textFieldAtIndex:0]text];if([n length])[_commandClient performAction:FTPCommandActionMakeDirectory host:_host port:_port username:_username password:_password path1:[self remotePathForName:n] path2:nil];}else if(a==_renameAlert&&_pendingIndexPath){NSString*n=[[a textFieldAtIndex:0]text];NSDictionary*d=[_items objectAtIndex:_pendingIndexPath.row];if([n length])[_commandClient performAction:FTPCommandActionRename host:_host port:_port username:_username password:_password path1:[self remotePathForName:[d objectForKey:@"name"]] path2:[self remotePathForName:n]];}}
- (void)ftpBrowserDidStart:(FTPBrowser*)b path:(NSString*)p{_connectButton.enabled=NO;_statusLabel.text=[NSString stringWithFormat:@"Listeleniyor: %@",p];}
- (void)ftpBrowser:(FTPBrowser*)b didFinishWithItems:(NSArray*)a path:(NSString*)p{[_items release];_items=[a copy];_connectButton.enabled=YES;[self setCurrentDirectoryPath:p];_statusLabel.text=[NSString stringWithFormat:@"%lu öğe — %@",(unsigned long)[a count],_currentPath];[_tableView reloadData];}
- (void)ftpBrowser:(FTPBrowser*)b didFailWithError:(NSError*)e{_connectButton.enabled=YES;_statusLabel.text=[NSString stringWithFormat:@"Listeleme hatası: %@",[e localizedDescription]];}
- (NSString*)percentEncodedPath:(NSString*)path {
 CFStringRef escaped=CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)path,NULL,CFSTR(":/?@&=+$,#[]!()*'"),kCFStringEncodingUTF8);
 return [(NSString*)escaped autorelease];
}
- (NSURL*)handoffURLWithScheme:(NSString*)scheme action:(NSString*)action path:(NSString*)path {
 NSString*encoded=[self percentEncodedPath:path];
 NSString*s=[NSString stringWithFormat:@"%@://%@?path=%@",scheme,action,encoded];
 return [NSURL URLWithString:s];
}
- (void)showDownloadCompletionForPath:(NSString*)path {
 [_completedDownloadPath release];_completedDownloadPath=[path copy];
 [_completionSheet release];_completionSheet=nil;
 BOOL isPDF=[[[path pathExtension] lowercaseString] isEqualToString:@"pdf"];
 if(isPDF){
  _completionSheet=[[UIActionSheet alloc]initWithTitle:@"İndirme tamamlandı" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"PDFReader ile Aç",@"Dosyalarda Göster",nil];
 }else{
  _completionSheet=[[UIActionSheet alloc]initWithTitle:@"İndirme tamamlandı" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Dosyalarda Göster",nil];
 }
 NSInteger cancel=[_completionSheet addButtonWithTitle:@"Tamam"];_completionSheet.cancelButtonIndex=cancel;[_completionSheet showInView:_window];
}
- (void)openCompletedPathInPDFReader {
 NSURL*u=[self handoffURLWithScheme:@"ipad1pdf" action:@"open" path:_completedDownloadPath];
 if(u&&[[UIApplication sharedApplication]canOpenURL:u])[[UIApplication sharedApplication]openURL:u];
 else _statusLabel.text=@"iPad1PDFReader bulunamadı veya URL scheme hazır değil.";
}
- (void)showCompletedPathInFiles {
 NSURL*u=[self handoffURLWithScheme:@"ipad1files" action:@"show" path:_completedDownloadPath];
 if(u&&[[UIApplication sharedApplication]canOpenURL:u])[[UIApplication sharedApplication]openURL:u];
 else _statusLabel.text=@"iPad1Files URL scheme henüz kullanılamıyor.";
}
- (void)ftpDownloaderDidStart:(FTPDownloader*)d destination:(NSString*)p{_bytesLabel.text=@"İndirme başladı...";}
- (void)ftpDownloader:(FTPDownloader*)d didReceiveBytes:(unsigned long long)n{NSTimeInterval e=[NSDate timeIntervalSinceReferenceDate]-_downloadStart;double sp=e>.05?n/e:0;if(_downloadExpected>0){float pr=(float)((double)n/_downloadExpected);if(pr>1)pr=1;_progressView.progress=pr;_bytesLabel.text=[NSString stringWithFormat:@"%d%% • %@ / %@ • %@",(int)(pr*100),[self sizeText:n],[self sizeText:_downloadExpected],[self speedText:sp]];}else _bytesLabel.text=[NSString stringWithFormat:@"%@ • %@",[self sizeText:n],[self speedText:sp]];}
- (void)ftpDownloaderDidFinish:(FTPDownloader*)d destination:(NSString*)p bytes:(unsigned long long)n{_progressView.progress=1;_statusLabel.text=@"İndirme tamamlandı";_bytesLabel.text=[NSString stringWithFormat:@"%@ • %@",[self sizeText:n],p];[self showDownloadCompletionForPath:p];}
- (void)ftpDownloader:(FTPDownloader*)d didFailWithError:(NSError*)e{_statusLabel.text=[NSString stringWithFormat:@"İndirme hatası: %@",[e localizedDescription]];}
- (void)ftpUploaderDidStart:(FTPUploader*)u source:(NSString*)s totalBytes:(unsigned long long)t{_progressView.progress=0;_statusLabel.text=[NSString stringWithFormat:@"Yükleniyor: %@",[s lastPathComponent]];}
- (void)ftpUploader:(FTPUploader*)u didSendBytes:(unsigned long long)n totalBytes:(unsigned long long)t bytesPerSecond:(double)sp{float p=t?(float)((double)n/t):0;if(p>1)p=1;_progressView.progress=p;_bytesLabel.text=[NSString stringWithFormat:@"Upload %d%% • %@ / %@ • %@",(int)(p*100),[self sizeText:n],[self sizeText:t],[self speedText:sp]];}
- (void)ftpUploaderDidFinish:(FTPUploader*)u remotePath:(NSString*)p bytes:(unsigned long long)n{_progressView.progress=1;_statusLabel.text=@"Upload tamamlandı";[self refresh];}
- (void)ftpUploader:(FTPUploader*)u didFailWithError:(NSError*)e{_statusLabel.text=[NSString stringWithFormat:@"Upload hatası: %@",[e localizedDescription]];}
- (void)ftpCommandClient:(FTPCommandClient*)c didFinishAction:(FTPCommandAction)a{_statusLabel.text=@"FTP işlemi tamamlandı.";[self refresh];}
- (void)ftpCommandClient:(FTPCommandClient*)c didFailWithError:(NSError*)e{_statusLabel.text=[NSString stringWithFormat:@"FTP işlem hatası: %@",[e localizedDescription]];}
- (void)dealloc{_browser.delegate=nil;[_browser release];_downloader.delegate=nil;[_downloader release];_uploader.delegate=nil;[_uploader release];_commandClient.delegate=nil;[_commandClient release];[_items release];[_currentPath release];[_host release];[_username release];[_password release];[_pendingIndexPath release];[_completedDownloadPath release];[_serversSheet release];[_uploadSheet release];[_completionSheet release];[_saveAlert release];[_renameAlert release];[_folderAlert release];[_hostField release];[_portField release];[_userField release];[_passField release];[_pathField release];[_connectButton release];[_upButton release];[_serversButton release];[_saveButton release];[_uploadButton release];[_newFolderButton release];[_statusLabel release];[_bytesLabel release];[_progressView release];[_tableView release];[_window release];[super dealloc];}
@end
