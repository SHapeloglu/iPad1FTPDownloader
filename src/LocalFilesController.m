#import "LocalFilesController.h"

@implementation LocalFilesController

- (id)initWithDirectory:(NSString *)d {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _directory = [d copy];
        self.title = @"İndirilenler";
    }
    return self;
}

- (void)dealloc {
    [_directory release];
    [_files release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_files release];
    NSArray *names = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directory error:nil];
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *name in names) {
        BOOL isDirectory = NO;
        NSString *path = [_directory stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory)
            [files addObject:name];
    }
    _files = [files copy];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_files count];
}

- (NSString *)sizeText:(unsigned long long)bytes {
    if (bytes >= 1073741824ULL) return [NSString stringWithFormat:@"%.2f GB", (double)bytes / 1073741824.0];
    if (bytes >= 1048576ULL) return [NSString stringWithFormat:@"%.2f MB", (double)bytes / 1048576.0];
    if (bytes >= 1024ULL) return [NSString stringWithFormat:@"%.1f KB", (double)bytes / 1024.0];
    return [NSString stringWithFormat:@"%llu B", bytes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DownloadedFile";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];

    NSString *name = [_files objectAtIndex:indexPath.row];
    NSString *path = [_directory stringByAppendingPathComponent:name];
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [self sizeText:[[attrs objectForKey:NSFileSize] unsignedLongLongValue]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString *)percentEncodedPath:(NSString *)path {
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (CFStringRef)path,
                                                                  NULL,
                                                                  CFSTR(":/?@&=+$,#[]!()*'"),
                                                                  kCFStringEncodingUTF8);
    return [(NSString *)escaped autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name = [_files objectAtIndex:indexPath.row];
    NSString *path = [_directory stringByAppendingPathComponent:name];
    NSString *scheme = [[[[name pathExtension] lowercaseString] description] isEqualToString:@"pdf"] ? @"ipad1pdf://open?path=" : @"ipad1files://show?path=";
    NSURL *url = [NSURL URLWithString:[scheme stringByAppendingString:[self percentEncodedPath:path]]];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        return;
    }

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Dosya indirildi"
                                                     message:@"Bu dosyayı açacak kardeş uygulamanın URL scheme'i henüz kullanılamıyor. Dosya ortak Downloads klasöründe korunuyor."
                                                    delegate:nil
                                           cancelButtonTitle:@"Tamam"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

@end
