#import <UIKit/UIKit.h>
#import "FTPDownloader.h"
#import "FTPUploader.h"
#import "FTPBrowser.h"
#import "FTPCommandClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,FTPDownloaderDelegate,FTPUploaderDelegate,FTPBrowserDelegate,FTPCommandClientDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate> {
 UIWindow *_window;
 UITextField *_hostField,*_portField,*_userField,*_passField,*_pathField,*_searchField;
 UIButton *_connectButton,*_upButton,*_serversButton,*_saveButton,*_uploadButton,*_newFolderButton,*_sortButton;
 UILabel *_statusLabel,*_bytesLabel;
 UIProgressView *_progressView;
 UITableView *_tableView;

 FTPDownloader *_downloader;
 FTPUploader *_uploader;
 FTPBrowser *_browser;
 FTPCommandClient *_commandClient;

 NSArray *_items,*_allItems;
 NSString *_currentPath,*_host,*_username,*_password;
 NSInteger _port;
 NSInteger _sortMode;
 BOOL _foldersFirst;
 unsigned long long _downloadExpected;
 NSTimeInterval _downloadStart;

 UIActionSheet *_serversSheet,*_uploadSheet,*_completionSheet,*_sortSheet;
 UIAlertView *_saveAlert,*_renameAlert,*_folderAlert;
 NSIndexPath *_pendingIndexPath;
 NSString *_completedDownloadPath;
}
@property(nonatomic,retain)UIWindow *window;
@end
