#import <UIKit/UIKit.h>
#import "WiFiReceiveServer.h"

@interface WiFiReceiveViewController : UIViewController <WiFiReceiveServerDelegate> {
    WiFiReceiveServer *_server;
    UILabel *_urlLabel;
    UILabel *_tokenLabel;
    UILabel *_statusLabel;
    UILabel *_progressLabel;
    UIProgressView *_progress;
    UIButton *_toggleButton;
    NSString *_completedPath;
}
@end
