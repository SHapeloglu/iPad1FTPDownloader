#import "UnifiedAppDelegate.h"
#import "HTTPDownloadViewController.h"
#import "WiFiReceiveViewController.h"

@implementation UnifiedAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL ok=[super application:application didFinishLaunchingWithOptions:launchOptions];
    if(!ok) return NO;

    UIViewController *ftp=self.window.rootViewController;
    ftp.title=@"FTP";
    ftp.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"FTP" image:nil tag:0] autorelease];

    HTTPDownloadViewController *http=[[[HTTPDownloadViewController alloc] init] autorelease];
    UINavigationController *httpNav=[[[UINavigationController alloc] initWithRootViewController:http] autorelease];
    httpNav.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"HTTP" image:nil tag:1] autorelease];

    WiFiReceiveViewController *wifi=[[[WiFiReceiveViewController alloc] init] autorelease];
    UINavigationController *wifiNav=[[[UINavigationController alloc] initWithRootViewController:wifi] autorelease];
    wifiNav.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Wi-Fi Al" image:nil tag:2] autorelease];

    UITabBarController *tabs=[[[UITabBarController alloc] init] autorelease];
    tabs.viewControllers=[NSArray arrayWithObjects:ftp,httpNav,wifiNav,nil];
    self.window.rootViewController=tabs;
    return YES;
}
@end
