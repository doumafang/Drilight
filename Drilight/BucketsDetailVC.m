//define
#import "DEFINE.h"

//VC+delegate
#import "BucketsDetailVC.h"
#import "AppDelegate.h"
#import "DetailVC.h"


//model
#import "BUCKETS.h"
#import "IMAGES.h"


//frame
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"


@interface BucketsDetailVC ()
@property NSString *access_token;
@property AppDelegate *myDelegate;
@end

@implementation BucketsDetailVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    self.myDelegate = [[UIApplication sharedApplication]delegate];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
