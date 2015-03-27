

#import "ListVC.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "RESideMenu.h"

#import "USER.h"
#import "DEFINE.h"
#import "ShotsVC.h"
#import "SettingVC.h"
#import "DFUserVC.h"


@interface ListVC ()<UITableViewDataSource,UITableViewDelegate>

{
    UIImageView *_avatarV;
    UIButton *_userB;
}

@property  NSString * access_token;
@property  AppDelegate * myDelegate;
@property  NSIndexPath * recordIndexPath;
@property  UITableView *listV;
@property  USER *user;

@end

@implementation ListVC
- (void)viewDidLoad {
    
    float viewX = self.view.frame.size.width *  2/3 ;
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
    [avatarV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarAction)]];
    [self.view addSubview:avatarV];


    _avatarV = avatarV;
    
    
    UITableView *listV = [[UITableView alloc] initWithFrame:CGRectMake(viewX/7, viewY/3 - 20 , viewX/7*5, viewY-viewY/3) style: UITableViewStyleGrouped];
    listV.delegate = self;
    listV.dataSource = self;
    listV.scrollEnabled = NO;
    listV.backgroundColor = [UIColor clearColor];
    listV.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.listV = listV];
    
    
    if (self.access_token) {
        [self userNerAction];
    }//第一次登陆之后
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNerAction) name:@"refresh" object:nil];
    
}

-(void)avatarAction

{
    NSLog(@"%@",self.user.userid);
    DFUserVC *userVC =[[DFUserVC alloc]init];
    [self.listV deselectRowAtIndexPath:self.recordIndexPath animated:YES];
    userVC.userID = self.user.userid;
    userVC.userObjectID = [self.user objectID];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:userVC] animated:YES ];
    [self.sideMenuViewController hideMenuViewController];

}

-(CGFloat )sizeOfName:(NSString *)str
{
    UIFont *font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [str boundingRectWithSize:CGSizeMake(1000, 20) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size.width;
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
        
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self userDelete];

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
                
                float viewX = self.view.frame.size.width * 0.67 ;

                if (!_userB) {
                    UIButton *userB = [[UIButton alloc]initWithFrame:CGRectMake((viewX - [self sizeOfName:user.name] - 10)/2, viewX/3 + viewX/2 - 50, [self sizeOfName:user.name] + 10, 24)];
                    
                    [userB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [userB.titleLabel setFont:[UIFont systemFontOfSize:13]];
                    [userB setTitle:user.name forState:UIControlStateNormal];
                    [userB addTarget:self action:@selector(avatarAction) forControlEvents:UIControlEventTouchUpInside];
                    
                    _userB = userB;

                }
                
                [self.view addSubview:_userB ];
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

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerV = [[UIView alloc]init];
    headerV.backgroundColor = [UIColor clearColor];
    UIView *lineV =[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.size.width/10, 10, tableView.frame.size.width *4/5, 0.5)];
    lineV.backgroundColor = [UIColor whiteColor];
    [headerV addSubview:lineV];
    return headerV;

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
                    self.recordIndexPath = indexPath;
                }
                    break;
                case 1:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"animated";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                    self.recordIndexPath = indexPath;

                }
                    
                    break;
                case 2:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"debuts";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                    self.recordIndexPath = indexPath;

                }
                    break;
                case 3:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"playoffs";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                    self.recordIndexPath = indexPath;

                }
                    break;
                case 4:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"rebounds";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    
                    [self.sideMenuViewController hideMenuViewController];
                    self.recordIndexPath = indexPath;

                }
                    
                    
                    break;
                case 5:
                {
                    ShotsVC *shotsVC =[[ShotsVC alloc]init];
                    shotsVC.listStr = @"teams";
                    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:shotsVC] animated:YES ];
                    [self.sideMenuViewController hideMenuViewController];
                    self.recordIndexPath = indexPath;

                }
                    break;
                    
            }
            break;
        case 1:
        {
            SettingVC *settingVC =[[SettingVC alloc]init];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:settingVC] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            self.recordIndexPath = indexPath;

            
        }
            break;
    }
    
}


#pragma mark -
#pragma mark UITableViewDataSource

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * menuArray1 = [NSArray arrayWithObjects:@"completed",@"animated",@"debuts",@"playoffs",@"rebounds",@"teams",nil];
    NSArray * menuArray2 = [NSArray arrayWithObjects:@"setting", nil];
    NSArray *menuArray  = [NSArray arrayWithObjects:menuArray1, menuArray2,nil];
    
    
    
    static NSString *douma = @"douma";
    
    UITableViewCell *listCells = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:douma];
    if (listCells == nil) {
        listCells = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:douma];
    }
    
    listCells.backgroundColor = [UIColor clearColor];
    listCells.tintColor = [UIColor whiteColor];
    listCells.textLabel.font = [UIFont systemFontOfSize:13];
    listCells.textLabel.textColor = [UIColor whiteColor];
    listCells.textLabel.highlightedTextColor = RGBA(241, 92, 149, 1);
    
    NSString *name = [[menuArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    NSString *imageName = [NSString stringWithFormat:@"%@_slide_1",name];
    NSString *imageHighlightName = [NSString stringWithFormat:@"%@_slide_2",name];
    NSString *str = [name capitalizedStringWithLocale:[NSLocale currentLocale]];

    listCells.imageView.image = [UIImage imageNamed:imageName];
    listCells.imageView.highlightedImage = [UIImage imageNamed:imageHighlightName];
    listCells.textLabel.text = str;
    
    listCells.selectionStyle = UITableViewCellSelectionStyleBlue;
    listCells.selectedBackgroundView = [[UIView alloc]initWithFrame:listCells.frame];
    listCells.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    return listCells;

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



#pragma mark -
#pragma mark Other

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
}

@end
