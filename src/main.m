#import <UIKit/UIKit.h>
#import "UnifiedAppDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([UnifiedAppDelegate class]));
    [pool drain];
    return retVal;
}
