#import "DFUserVC.h"
#import "RESideMenu.h"
#import "USER.h"

@interface DFUserVC ()

@end

@implementation DFUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setNavigationBar
{
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"leftBBI"]
                                                 landscapeImagePhone:nil
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(leftAction)];
    self.navigationItem.leftBarButtonItem = leftBBI;
    
}

-(void)leftAction
{
    [self.sideMenuViewController presentLeftMenuViewController];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
