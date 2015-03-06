

#import "SettingVC.h"
#import "DEFINE.h"
#import "RESideMenu.h"
#import "SignVC.h"

@interface SettingVC ()<MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BG_COLOR;
    
    [self setNav];
    [self setListV];
    
    
}

-(void)setListV
{
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"drilight_setting"]];
    imageV.frame = CGRectMake(SCREENX*3/8, SCREENX/6, SCREENX/4, SCREENX/4);
    [self.view addSubview:imageV];
    
    UILabel *drilightL = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.frame.size.height + imageV.frame.origin.y + 20, SCREENX, 20)];
    drilightL.text = @"Drilight Designed for Drilbbble";
    drilightL.font = [UIFont systemFontOfSize:13];
    drilightL.numberOfLines = 2;
    drilightL.textAlignment = NSTextAlignmentCenter;
    drilightL.textColor = RGBA(241, 92, 149, 1 );
    [self.view addSubview:drilightL];
    
    
    
    UITableView *listV = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREENY/3, SCREENX, 300) style:UITableViewStyleGrouped];
    listV.delegate = self;
    listV.dataSource = self;
    listV.backgroundColor = [UIColor clearColor];
    listV.scrollEnabled = NO;
    listV.clipsToBounds = YES;
    listV.tableFooterView.backgroundColor = [UIColor clearColor];
    listV.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:listV];
    
    UIImageView *uniquestudioV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"uniquestudio_setting"]];
    uniquestudioV.frame = CGRectMake(SCREENX*3/8, SCREENY * 9/12, SCREENY/6, SCREENY/6);
    [self.view addSubview:uniquestudioV];
    
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 1;
    switch (section) {
        case 0:
            number = 3;
            break;
            
        case 1:
            number = 1;
            break;
    }
    return number;
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.width/8;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString * cellRE = @"cellRE";
    NSArray *array1 = @[@"Rate Drilight",@"Feedback",@"Version"];
    NSArray *array2 = @[@"Sign Out"];
    NSArray *array = @[array1,array2];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRE];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[array objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if (indexPath.row == 2) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellRE];
        cell.textLabel.text = @"Version";
        cell.detailTextLabel.text = @"1.0";
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    if (indexPath.section == 1) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = RGBA(241, 92, 149, 1 );
    }
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
                case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
                        [self sendEmailAction]; // 调用发送邮件的代码
                    }
                    
                }
                    break;
                case 2:
                {
                    
                }
                    break;
                    
            }

        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"access_token"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [SignVC show];
                [self performSelector:@selector(joke) withObject:self afterDelay:0.4f];
            }
        }
            break;
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)joke
{
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:[[ShotsVC alloc]init]] animated:NO];

}

- (void)sendEmailAction
{
    
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    [mailCompose setMailComposeDelegate:self];
    [mailCompose setSubject:@"Drilight Help and Feedback"];
    [mailCompose setToRecipients:@[@"drilight.studio@gmail.com"]];
    [mailCompose setCcRecipients:@[@"xifang@hustunique.com"]];
    NSMutableString *body = [NSMutableString string];
    
    [body appendString:@"<h1>Hello Drilight User!</h1>\n"];
    [body appendString:@"<a href=\"http://www.drilight.us\">Click Me!</a>\n"];
    [body appendString:@"<div>Thanks much!</div>\n"];
    
    [mailCompose setMessageBody:body isHTML:YES];
    
    [self presentViewController:mailCompose animated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark SetNav

-(void)setNav
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UI_NAVIGATION_BAR_HEIGHT, UI_NAVIGATION_BAR_HEIGHT)];
    
    titleLabel.text = @"Setting";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.userInteractionEnabled = YES;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    self.navigationItem.titleView = titleLabel;
    
    
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"leftBBI"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    self.navigationItem.leftBarButtonItem = leftBBI;
    

    
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}

#pragma mark NavAction

-(void)leftAction
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
