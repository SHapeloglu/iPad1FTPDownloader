#import <UIKit/UIKit.h>
#import "HTTPDownloadTask.h"

@interface HTTPDownloadViewController : UIViewController <HTTPDownloadTaskDelegate,UITextFieldDelegate,UIActionSheetDelegate> {
    UITextField *_urlField;
    UIButton *_startButton;
    UIButton *_cancelButton;
    UIProgressView *_progress;
    UILabel *_status;
    UILabel *_speed;
    HTTPDownloadTask *_task;
    NSString *_completedPath;
}
@end
