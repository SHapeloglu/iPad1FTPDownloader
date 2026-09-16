#import "UnifiedAppDelegate.h"
#import "HTTPDownloadViewController.h"
#import "WiFiReceiveViewController.h"

@implementation UnifiedAppDelegate

- (void)dismissTransferModal {
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

- (UINavigationController *)navigationControllerForRoot:(UIViewController *)root title:(NSString *)title {
    root.title=title;
    root.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTransferModal)] autorelease];
    UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:root] autorelease];
    nav.modalPresentationStyle=UIModalPresentationFullScreen;
    return nav;
}

- (void)openHTTPDownloader {
    HTTPDownloadViewController *vc=[[[HTTPDownloadViewController alloc] init] autorelease];
    UINavigationController *nav=[self navigationControllerForRoot:vc title:@"HTTP / HTTPS"];
    [self.window.rootViewController presentModalViewController:nav animated:YES];
}

- (void)openWiFiReceive {
    WiFiReceiveViewController *vc=[[[WiFiReceiveViewController alloc] init] autorelease];
    UINavigationController *nav=[self navigationControllerForRoot:vc title:@"Wi-Fi Al"];
    [self.window.rootViewController presentModalViewController:nav animated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL ok=[super application:application didFinishLaunchingWithOptions:launchOptions];
    if(!ok) return NO;

    UIViewController *ftp=self.window.rootViewController;
    if(!ftp || !ftp.view) return YES;

    UIButton *http=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    http.frame=CGRectMake(22,14,100,32);
    [http setTitle:@"HTTP" forState:UIControlStateNormal];
    [http addTarget:self action:@selector(openHTTPDownloader) forControlEvents:UIControlEventTouchUpInside];
    [ftp.view addSubview:http];

    UIButton *wifi=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    wifi.frame=CGRectMake(646,14,100,32);
    [wifi setTitle:@"Wi-Fi Al" forState:UIControlStateNormal];
    [wifi addTarget:self action:@selector(openWiFiReceive) forControlEvents:UIControlEventTouchUpInside];
    [ftp.view addSubview:wifi];

    return YES;
}
@end
