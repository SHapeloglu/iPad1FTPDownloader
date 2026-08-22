#import <Foundation/Foundation.h>
@interface TransferQueueItem : NSObject {
    NSString *_remotePath; NSString *_localPath; NSString *_displayName;
    BOOL _upload; BOOL _resume;
}
@property(nonatomic,copy) NSString *remotePath;
@property(nonatomic,copy) NSString *localPath;
@property(nonatomic,copy) NSString *displayName;
@property(nonatomic,assign) BOOL upload;
@property(nonatomic,assign) BOOL resume;
@end
@interface TransferQueue : NSObject { NSMutableArray *_items; }
- (void)addItem:(TransferQueueItem *)item;
- (TransferQueueItem *)popNextItem;
- (NSArray *)allItems;
- (NSUInteger)count;
@end
