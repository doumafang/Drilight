

#import "ListVC.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "USER.h"
#import "RESideMenu.h"

#import "DEFINE.h"
#import "ShotsVC.h"
#import "SettingVC.h"



@interface ListVC ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_avatarV;
    UILabel *_userL;
}
@property  NSString * access_token;
@property  AppDelegate * myDelegate;
@property USER *user;
@end

@implementation ListVC
- (void)viewDidLoad {
    
    float viewX = self.view.frame.size.width / 5*4 ;
    float viewY = self.view.frame.size.height;
    
    [super viewDidLoad];
    
    
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];


    UIImageView *avatarV = [[UIImageView alloc]initWithFrame:CGRectMake(viewX/3,viewX/2-50 , viewX/3, viewX/3)];
    avatarV.layer.borderColor = [UIColor whiteColor].CGColor;
    avatarV.layer.borderWidth = 2.0f;
    avatarV.layer.masksToBounds = YES;
    avatarV.layer.cornerRadius = viewX/6;
    avatarV.userInteractionEnabled = YES;
    avatarV.opaque = YES;
    [self.view addSubview:avatarV];

    
    
    
    _avatarV = avatarV;
    
    
    
    UILabel *userL = [[UILabel alloc]initWithFrame:CGRectMake(0, avatarV.frame.size.height+avatarV.frame.origin.y+10, viewX, 20)];
    userL.textAlignment = NSTextAlignmentCenter;
    userL.userInteractionEnabled = YES;
    userL.textColor = [UIColor whiteColor];
    userL.font = [UIFont fontWithName:@"Nexa Bold" size:13];
    [self.view addSubview:userL];
    _userL = userL;
    
    
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(40, userL.frame.origin.y+userL.frame.size.height, viewX-80, 0.5)];
    lineV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineV];
    
    
    
    UITableView *listV = [[UITableView alloc]initWithFrame:CGRectMake(avatarV.frame.origin.x-15, userL.frame.size.height+userL.frame.origin.y+15, viewX/7*5, viewY-userL.frame.size.height-userL.frame.origin.y) style:UITableViewStyleGrouped];
    listV.delegate = self;
    listV.dataSource = self;
    listV.scrollEnabled = NO;
    listV.backgroundColor = [UIColor clearColor];
    listV.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:listV];
    
    if (self.access_token) {
        [self userNerAction];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNerAction) name:@"refresh" object:nil];

    
}


-(void)userNerAction
{
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    BACK((^{
        NSString *str = [[NSString stringWithFormat:@"https://api.dribbble.com/v1/user?access_token=%@",self.access_token]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self userDelete];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            USER *user = EntityObjects(@"USER");
            
            user.source = @"self";
            
            user.avatar_url = [dic objectForKey:@"avatar_url"];
            
            user.name = [dic  objectForKey:@"name"];
            
            user.userid = [[dic objectForKey:@"id"]stringValue];
            
            user.shots_count = [[dic objectForKey:@"shots_count"]stringValue];
            user.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
            user.buckets_count = [[dic objectForKey:@"buckets_count"]stringValue];
            
            user.followers_count = [[dic objectForKey:@"followers_count"]stringValue];
            user.followings_count = [[dic objectForKey:@"followings_count"]stringValue];
            
            user.pro = [[dic objectForKey:@"pro"]stringValue];
            user.bio = [dic objectForKey:@"user"];
            
            if ( [[[dic objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
            {
                user.web = [[dic objectForKey:@"links"] objectForKey:@"web"];
            }
            if ( [[[dic objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
            {
                user.twitter = [[dic objectForKey:@"links"] objectForKey:@"twitter"];
            }

            if ([[dic  objectForKey:@"location"]class] != [NSNull class]) {
                user.location = [dic  objectForKey:@"location"];
            }
            
            [self douma_save];
            
            self.user = user;
            
            MAIN((^{
                NSURL *url = [NSURL URLWithString:[user.avatar_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [_avatarV setImageWithURL:url];
                [_userL setText:user.name];
            }));
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error:%@ ___ %@",error ,[error userInfo]);
        }];
        [operation start];
        
    }));
    
}


-(void )userDelete
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"USER" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSString *str = @"self";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source = %@", str];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.myDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (USER *object in fetchedObjects) {
        [self.myDelegate.managedObjectContext deleteObject:object];
    }
    [self douma_save];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = 6;
    
    switch (section) {
        case 0:
            number = 6;
            break;
        case 1:
            number = 1;
            break;
         }
    return number;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footV = [[UIView alloc]init];
    footV.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        UIView *lineV =[[UIView alloc]initWithFrame:CGRectMake(15, 10, 90, 0.5)];
        lineV.backgroundColor = [UIColor whiteColor];
        [footV addSubview:lineV];
    }
    return footV;

}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * menuArray1 = [NSArray arrayWithObjects:@"Completed",@"Animated",@"Debuts",@"Playoffs",@"Rebounds",@"Teams",nil];
    NSArray * menuArray2 = [NSArray arrayWithObjects:@"Setting", nil];
    
    NSArray *menuArray  = [NSArray arrayWithObjects:menuArray1, menuArray2,nil];
    
    
    
    static NSString *douma = @"douma";
    
    UITableViewCell *listCells = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:douma];
    if (listCells == nil) {
        listCells = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:douma];
    }
    listCells.backgroundColor = [UIColor clearColor];
    listCells.tintColor = [UIColor whiteColor];
    listCells.textLabel.font = [UIFont systemFontOfSize:15];
    listCells.textLabel.textColor = [UIColor whiteColor];
    listCells.textLabel.highlightedTextColor = [UIColor colorWithRed:254/255.0 green:142/255.0 blue:185/255.0 alpha:1.0];
    
   
    listCells.textLabel.text = [[menuArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    listCells.selectionStyle = UITableViewCellSelectionStyleBlue;
    listCells.selectedBackgroundView = [[UIView alloc]initWithFrame:listCells.frame];
    listCells.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    return listCells;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"completed";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                }
                    break;
                case 1:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"animated";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                }

                    break;
                case 2:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"debuts";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                }
                    break;
                case 3:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"playoffs";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                }
                    break;
                case 4:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"rebounds";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                }


                    break;
                case 5:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"teams";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    [self.sideMenuViewController hideMenuViewController];
                }
                    break;

            }
            break;
        case 1:
        {
            SettingVC *settingVC =[[SettingVC alloc]init];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:settingVC] animated:YES ];
            [self.sideMenuViewController hideMenuViewController];

        }
                break;
       }
    
}


-(void)douma_save
{
    NSError *error = nil;
    if (![self.myDelegate.managedObjectContext save:&error])
    {
        NSLog(@"Error%@:%@",error,[error userInfo]);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
