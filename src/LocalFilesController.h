#import <UIKit/UIKit.h>
@interface LocalFilesController : UITableViewController { NSString *_directory; NSArray *_files; }
- (id)initWithDirectory:(NSString *)directory;
@end
