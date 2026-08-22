#import <Foundation/Foundation.h>
@class FTPCommandClient;
typedef enum { FTPCommandActionDeleteFile=1, FTPCommandActionDeleteDirectory=2, FTPCommandActionMakeDirectory=3, FTPCommandActionRename=4 } FTPCommandAction;
@protocol FTPCommandClientDelegate <NSObject>
- (void)ftpCommandClient:(FTPCommandClient *)client didFinishAction:(FTPCommandAction)action;
- (void)ftpCommandClient:(FTPCommandClient *)client didFailWithError:(NSError *)error;
@end
@interface FTPCommandClient : NSObject <NSStreamDelegate> {
    id<FTPCommandClientDelegate> _delegate;
    NSInputStream *_inputStream; NSOutputStream *_outputStream; NSMutableData *_receiveData;
    NSString *_host,*_username,*_password,*_path1,*_path2; NSInteger _port,_state; FTPCommandAction _action; BOOL _finished;
}
@property (nonatomic, assign) id<FTPCommandClientDelegate> delegate;
- (void)performAction:(FTPCommandAction)action host:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password path1:(NSString *)path1 path2:(NSString *)path2;
- (void)cancel;
@end
