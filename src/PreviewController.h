#import <UIKit/UIKit.h>
@interface PreviewController : UIViewController { NSString *_filePath; UIView *_contentView; }
- (id)initWithFilePath:(NSString *)path;
@end
