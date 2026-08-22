#import "TransferQueue.h"
@implementation TransferQueueItem
@synthesize remotePath=_remotePath,localPath=_localPath,displayName=_displayName,upload=_upload,resume=_resume;
- (void)dealloc { [_remotePath release]; [_localPath release]; [_displayName release]; [super dealloc]; }
@end
@implementation TransferQueue
- (id)init { self=[super init]; if(self) _items=[[NSMutableArray alloc]init]; return self; }
- (void)dealloc { [_items release]; [super dealloc]; }
- (void)addItem:(TransferQueueItem *)item { if(item) [_items addObject:item]; }
- (TransferQueueItem *)popNextItem { if(![_items count]) return nil; TransferQueueItem *i=[[_items objectAtIndex:0] retain]; [_items removeObjectAtIndex:0]; return [i autorelease]; }
- (NSArray *)allItems { return _items; }
- (NSUInteger)count { return [_items count]; }
@end
