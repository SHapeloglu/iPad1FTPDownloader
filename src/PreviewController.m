#import "PreviewController.h"
@implementation PreviewController
- (id)initWithFilePath:(NSString *)path { self=[super init]; if(self){ _filePath=[path copy]; self.title=[path lastPathComponent]; } return self; }
- (void)dealloc { [_filePath release]; [_contentView release]; [super dealloc]; }
- (void)viewDidLoad { [super viewDidLoad]; self.view.backgroundColor=[UIColor whiteColor]; NSString *e=[[_filePath pathExtension] lowercaseString];
    if([e isEqualToString:@"jpg"]||[e isEqualToString:@"jpeg"]||[e isEqualToString:@"png"]||[e isEqualToString:@"gif"]){ UIImageView *v=[[UIImageView alloc]initWithFrame:self.view.bounds]; v.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; v.contentMode=UIViewContentModeScaleAspectFit; v.image=[UIImage imageWithContentsOfFile:_filePath]; _contentView=v; }
    else if([e isEqualToString:@"txt"]||[e isEqualToString:@"log"]||[e isEqualToString:@"csv"]){ UITextView *v=[[UITextView alloc]initWithFrame:self.view.bounds]; v.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; v.editable=NO; NSString *s=[NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil]; if(!s)s=[NSString stringWithContentsOfFile:_filePath encoding:NSISOLatin1StringEncoding error:nil]; v.text=s?s:@"Dosya okunamadı."; _contentView=v; }
    else { UIWebView *v=[[UIWebView alloc]initWithFrame:self.view.bounds]; v.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; v.scalesPageToFit=YES; [v loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]]]; _contentView=v; }
    [self.view addSubview:_contentView];
}
@end
