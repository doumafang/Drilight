
#import "DEFINE.h"
#import "AppDelegate.h"
#import "UserVC.h"
#import "GPUImage.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

#import "USER.h"
#import "ShotsCell.h"
#import "FollowCell.h"

#import "SHOTS.h"
#import "IMAGES.h"
#import "AppDelegate.h"
#import "MJRefresh.h"

static NSString *shotsFootURL = nil;
static NSInteger shotsN = 12;
static NSString *likesFootURL = nil;
static NSInteger likesN = 12;
static NSString *followingFootURL = nil;
static NSInteger followingN = 12;
static NSString *followersFootURL = nil;
static NSInteger followersN = 12;



@interface UserVC ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate>
{
    UIView *_navV;
    
    UIImageView *_blackIV;
    UIImageView *_avatarBG;
    UIImageView *_avatarIV;
    UILabel *_userL;
    UIView *_mapV;

    UIScrollView *_listSV;
    UIScrollView *_mainSV;
    UIScrollView *_bgSV;
    
    UICollectionView *_shotsCV;
    UICollectionView *_likesCV;
    UICollectionView *_followingCV;
    UICollectionView *_followersCV;

    NSMutableArray *_shotsChanges;
    NSMutableArray *_likesChanges;
    NSMutableArray *_followingChanges;
    NSMutableArray *_followersChanges;
    NSMutableArray *_sectionChanges;
}

@property AppDelegate * myDelegate;
@property USER *user;
@property NSString *access_token;
@property (nonatomic)  NSFetchedResultsController *shotsFRC;
@property (nonatomic)  NSFetchedResultsController *likesFRC;
@property (nonatomic)  NSFetchedResultsController *followingFRC;
@property (nonatomic)  NSFetchedResultsController *followersFRC;
@end

@implementation UserVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BG_COLOR;
    
    [self setNavigationBar];
    
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    self.myDelegate = [[UIApplication sharedApplication]delegate];
    NSError *objectError= nil;
    
    NSManagedObject *userObject = [self.myDelegate.managedObjectContext existingObjectWithID:self.userObjectID error:&objectError];
    self.user = (USER *)userObject;
    
    
    UIScrollView *bgSV = [[UIScrollView alloc]initWithFrame:self.view.frame];
    bgSV.backgroundColor = BG_COLOR;
    bgSV.delegate = self;
    bgSV.bounces = YES;
    bgSV.bouncesZoom = YES;
    bgSV.showsHorizontalScrollIndicator = NO;
    bgSV.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgSV];
    _bgSV = bgSV;

    
    UIView *navV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navV.backgroundColor = RGBA(50, 50, 50, 0);
    [self.view addSubview:navV];
    _navV = navV;
    
    
    UIImageView *avatarBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*25/32)];
    avatarBG.userInteractionEnabled = YES;
    [bgSV addSubview:avatarBG];
    _avatarBG = avatarBG;

    float viewX = self.view.frame.size.width;
    
    NSURL *avatar_url = [NSURL URLWithString:self.user.avatar_url];
    UIImageView *avatarIV = [[UIImageView alloc ]init];
    [avatarIV sd_setImageWithURL:avatar_url];

    avatarIV.frame = CGRectMake(viewX * 3/8, viewX/4-10, viewX/4, viewX/4);
    avatarIV.layer.masksToBounds = YES;
    avatarIV.layer.cornerRadius = viewX/8;
    avatarIV.layer.borderColor = [UIColor whiteColor].CGColor;
    avatarIV.layer.borderWidth = 2.0f;
    _avatarIV = avatarIV;

    

   
    if (avatarIV.image) {
        BACK(^{
            GPUImageGaussianBlurFilter *mainViewImageFilter = [[GPUImageGaussianBlurFilter alloc]init];
            mainViewImageFilter.blurRadiusInPixels = 15;
            UIImage *filterImage = [mainViewImageFilter imageByFilteringImage:avatarIV.image];
            MAIN(^{
                [_avatarBG setImage:filterImage];

            });
        });
    }
    
    
    UIImageView *blackIV = [[UIImageView alloc]initWithFrame:avatarBG.frame];
    blackIV.image = [UIImage imageNamed:@"backBlack"];
    blackIV.userInteractionEnabled = YES;
    [avatarBG addSubview:blackIV];
    _blackIV = blackIV;
    [blackIV addSubview:avatarIV];

    
    
    UILabel *userL = [[UILabel alloc]initWithFrame:CGRectMake(0, avatarIV.frame.size.height+avatarIV.frame.origin.y, viewX, 40)];
    userL.text = self.user.name;
    userL.font = [UIFont fontWithName:@"Nexa Bold" size:15];
    userL.textColor = [UIColor whiteColor];
    userL.textAlignment = NSTextAlignmentCenter;


    [blackIV addSubview:userL];
    _userL = userL;
    
    
    
    UIFont *font = [UIFont fontWithName:@"Nexa Bold" size:12];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [self.user.location boundingRectWithSize:CGSizeMake(viewX, 20) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    float mapX = size.width + 18;
    
    UILabel *mapL = [[UILabel alloc]initWithFrame:CGRectMake(viewX/2 - mapX/2+18, 15-size.height/2, size.width, size.height)];
    mapL.textColor = [UIColor whiteColor];
    mapL.font = font;
    mapL.text = self.user.location;
    mapL.textAlignment = NSTextAlignmentCenter;
    

    UIImageView *mapI = [[UIImageView alloc]initWithFrame:CGRectMake(mapL.frame.origin.x - 18, 4, 18, 18)];
    mapI.image = [UIImage imageNamed:@"map"];


    
    
    UIView *lineL = [[UIView alloc]initWithFrame:CGRectMake(0, 29, viewX, 0.25)];
    lineL.backgroundColor = [UIColor whiteColor];
    
    
    
    UIView *mapV = [[UIView alloc]initWithFrame:CGRectMake(0, 30+ userL.frame.origin.y, viewX, 30)];
    mapV.userInteractionEnabled = YES;
    [blackIV addSubview:mapV];
    [mapV addSubview:mapI];
    [mapV addSubview:mapL];
    [mapV addSubview:lineL];
    _mapV = mapV;
    
    NSArray *listArray = [[NSArray alloc]initWithObjects:@"shots",@"likes",@"following",@"followers",@"about",nil];
    UIScrollView * listSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mapV.frame.size.height+mapV.frame.origin.y, viewX, avatarBG.frame.size.height-mapV.frame.origin.y-mapV.frame.size.height)];
    [listSV setShowsHorizontalScrollIndicator:NO];
    listSV.userInteractionEnabled = YES;

    listSV.scrollEnabled = YES;
    [blackIV insertSubview:listSV atIndex:0];
    _listSV = listSV;
    
    float sum = 20;
    for (int i = 0; i < listArray.count; i ++ ) {
        
        UIButton * listB = [UIButton buttonWithType:UIButtonTypeCustom];
        UIFont *listButtonFont = [UIFont fontWithName:@"Nexa Bold" size:15];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:listButtonFont, NSParagraphStyleAttributeName:paragraphStyle.copy};
        CGSize listSize = [[listArray objectAtIndex:i] boundingRectWithSize:CGSizeMake(1000, 20) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        [listB setFrame:CGRectMake(sum, listSV.frame.size.height/2-viewX*3/80, listSize.width + viewX * 2/32, viewX*3/40)];
        sum = sum + listSize.width + viewX * 3/32;
        listB.layer.masksToBounds = YES;
        listB.layer.cornerRadius = viewX * 3/80;
        [listB setTitle:[listArray objectAtIndex:i] forState:UIControlStateNormal];
        [listB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        listB.titleLabel.font = listButtonFont;
        listB.titleLabel.textAlignment = NSTextAlignmentCenter;
        [listB addTarget:self action:@selector(listButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        listB.tag = i + 1;
        if(i==0)
        {
            [self changeColorForButton:listB percent:1];
        }else
        {
            [self changeColorForButton:listB percent:0];
        }
        
        [listSV addSubview:listB];
    }
    [listSV setContentSize:CGSizeMake(sum, avatarBG.frame.size.height-mapV.frame.origin.y-mapV.frame.size.height)];

    UIScrollView *mainSV = [[UIScrollView alloc]initWithFrame:CGRectMake(0,blackIV.frame.size.height, self.view.frame.size.width,self.view.frame.size.height-64)];
    mainSV.delegate = self;
    mainSV.backgroundColor = BG_COLOR;
    mainSV.showsHorizontalScrollIndicator = NO;
    mainSV.showsVerticalScrollIndicator = NO;
    mainSV.pagingEnabled = YES;
    mainSV.bounces = NO;
    [self addView2Page:mainSV count:listArray.count];
    [bgSV addSubview:mainSV];
    _mainSV = mainSV;
    
    bgSV.contentSize = CGSizeMake(self.view.frame.size.width, blackIV.frame.size.height+mainSV.frame.size.height);

    [self shotsNetAction];
    [self likesNetAction];
    [self followingNetAction];
    [self followersNetAction];
}

#pragma mark - NetworkAction

-(void)shotsNetAction
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/shots?access_token=%@",self.userID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSString *lastModified = [[operation.response allHeaderFields]objectForKey:@"Last-Modified"];
            if (![self.user.shots_lastmodified isEqualToString:lastModified]) {
                if (self.user.shots_lastmodified != nil) {
                    [self.user removeShots:self.user.shots];
                }
                NSArray *array = (NSArray *)responseObject;
                NSInteger x = 0;
                
                
                
                NSRange footrange = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
                
                NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                     substringToIndex:footrange.location-1];
                shotsFootURL = footstr;

                
                for (NSDictionary *dic in array) {
                    SHOTS *object = EntityObjects(@"SHOTS");
                    object.shotsid = [[dic objectForKey:@"id"] stringValue];
                    if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                        object.shot_description = [dic objectForKey:@"description"];
                    }
                    object.title = [dic objectForKey:@"title"];
                    object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                    object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                    object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                    object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                    object.created_at = [dic objectForKey:@"created_at"];
                    object.source = @"userShots";
                    object.i = [NSNumber numberWithInteger:x];
                    
                    object.user = self.user;
                    NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                    object.tags = tagsData;
                    
                    IMAGES*images = EntityObjects(@"IMAGES");
                    object.images = images;
                    
                    if ([[[dic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                        images.hidpi = [[dic objectForKey:@"images"]objectForKey:@"hidpi"];
                    }
                    images.normal = [[dic objectForKey:@"images"]objectForKey:@"normal"];
                    images.teaser = [[dic objectForKey:@"images"]objectForKey:@"teaser"];
                    
                    x ++;
                    [self douma_save];
                }
                self.user.shots_lastmodified = lastModified;
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"%@",error);
        }];
        [operation start];
    }));
}

-(void)likesNetAction
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/likes?access_token=%@",self.userID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             
             NSRange footrange = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
             
             NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                  substringToIndex:footrange.location-1];
             likesFootURL = footstr;

             
             
             NSString *lastModified = [[operation.response allHeaderFields]objectForKey:@"Last-Modified"];
             if (![self.user.likes_lastmodified isEqualToString:lastModified]) {
                 if (self.user.likes_lastmodified != nil) {
                     [self.user removeLikes:self.user.likes];
                 }
                 NSArray *array = (NSArray *)responseObject;
                 NSInteger x = 0;
                 
                 for (NSDictionary *dic in array) {
                     SHOTS *object = EntityObjects(@"SHOTS");
                     NSDictionary *shotDic = [dic objectForKey:@"shot"];
                     object.shotsid = [[shotDic objectForKey:@"id"] stringValue];

                     if ([[shotDic objectForKey:@"description"]class] != [NSNull class]) {
                         object.shot_description = [shotDic objectForKey:@"description"];
                     }
                     object.title = [shotDic objectForKey:@"title"];
                     object.likes_count = [[shotDic objectForKey:@"likes_count"]stringValue];
                     object.comments_count = [[shotDic objectForKey:@"comments_count"]stringValue];
                     object.views_count = [[shotDic objectForKey:@"views_count"]stringValue];
                     object.attachments_count = [[shotDic objectForKey:@"attachments_count"]stringValue];
                     object.created_at = [shotDic objectForKey:@"created_at"];
                     object.source = @"userLikes";
                     object.i = [NSNumber numberWithInteger:x];
                     
                     object.likedby = self.user;
                    
                     USER *user = EntityObjects(@"USER");
                     object.user = user;
                     
                     user.avatar_url = [[shotDic objectForKey:@"user"]objectForKey:@"avatar_url"];
                     user.name = [[shotDic objectForKey:@"user"]objectForKey:@"name"];
                     user.shots_count = [[[shotDic objectForKey:@"user"]objectForKey:@"shots_count"]stringValue];
                     user.likes_count = [[[shotDic objectForKey:@"user"]objectForKey:@"likes_count"]stringValue];
                     user.followers_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followers_count"]stringValue];
                     user.followings_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followings_count"]stringValue];
                     
                     if ( [[[shotDic objectForKey:@"user"]objectForKey:@"location"]class] != [NSNull class])
                     {
                         user.location = [[shotDic objectForKey:@"user"]objectForKey:@"location"];
                     }
                     user.userid = [[[shotDic objectForKey:@"user"]objectForKey:@"id"]stringValue];
                     
                     NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                     object.tags = tagsData;
                     
                     IMAGES*images = EntityObjects(@"IMAGES");
                     object.images = images;
                     
                     if ([[[shotDic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                         images.hidpi = [[shotDic objectForKey:@"images"]objectForKey:@"hidpi"];
                     }
                     images.normal = [[shotDic objectForKey:@"images"]objectForKey:@"normal"];
                     images.teaser = [[shotDic objectForKey:@"images"]objectForKey:@"teaser"];
                     
                     x ++;
                     [self douma_save];
                 }
                 self.user.likes_lastmodified = lastModified;
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
         }];
        [operation start];
    }));
}

-(void)followingNetAction
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/following?access_token=%@",self.userID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             NSRange footrange = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
             
             NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                  substringToIndex:footrange.location-1];
             followingFootURL = footstr;

             
             
             NSString *lastModified = [[operation.response allHeaderFields]objectForKey:@"Last-Modified"];
             if (![self.user.following_lastmodified isEqualToString:lastModified]) {
                 if (self.user.following_lastmodified != nil) {
                     [self.user removeFollowing:self.user.following];
                 }
                 NSArray *array = (NSArray *)responseObject;
                 NSInteger x = 0;
                 
                 for (NSDictionary *dic in array) {
                     
                     USER *object = EntityObjects(@"USER");
                     
                     NSDictionary *followeeDic = [dic objectForKey:@"followee"];
                     
                     object.followingby = self.user;

                     object.source = @"userFollowing";
                     
                     object.i = [NSNumber numberWithInteger:x];
                     
                     object.userid = [[followeeDic objectForKey:@"id"] stringValue];
                     
                     object.pro = [[followeeDic objectForKey:@"pro"]stringValue];
                     
                     object.name = [followeeDic objectForKey:@"name"];

                     object.avatar_url = [followeeDic objectForKey:@"avatar_url"];
                     
                     object.shots_count = [[followeeDic objectForKey:@"shots_count"]stringValue];
                     
                     object.likes_count = [[followeeDic objectForKey:@"likes_count"]stringValue];
                     
                     object.followers_count = [[followeeDic objectForKey:@"followers_count"] stringValue];
                     
                     object.followings_count = [[followeeDic objectForKey:@"followings_count"] stringValue];
                     
                     if ( [[followeeDic objectForKey:@"location"]class] != [NSNull class])
                     {
                         object.location = [followeeDic objectForKey:@"location"];
                     }
                     
                     if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                     {
                         object.web = [[followeeDic objectForKey:@"links"] objectForKey:@"web"];
                     }
                     if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                     {
                         object.twitter = [[followeeDic objectForKey:@"links"] objectForKey:@"twitter"];
                     }
                     
                     x ++;
                     [self douma_save];
                 }
                 self.user.following_lastmodified = lastModified;
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
         }];
        [operation start];
    }));
}

-(void)followersNetAction
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/followers?access_token=%@",self.userID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             NSRange footrange = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
             
             NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                  substringToIndex:footrange.location-1];
             followersFootURL = footstr;
             
             
             
             NSString *lastModified = [[operation.response allHeaderFields]objectForKey:@"Last-Modified"];
             if (![self.user.followers_lastmodified isEqualToString:lastModified]) {
                 if (self.user.followers_lastmodified != nil) {

                 }
             
                 
                 NSArray *array = (NSArray *)responseObject;
                 NSInteger x = 0;
                 
                 for (NSDictionary *dic in array) {
                     
                     USER *object = EntityObjects(@"USER");
                     
                     NSDictionary *followeeDic = [dic objectForKey:@"follower"];
                     
                     object.followersby = self.user;
                     
                     object.source = @"userFollowed";
                     
                     object.i = [NSNumber numberWithInteger:x];
                     
                     object.userid = [[followeeDic objectForKey:@"id"] stringValue];
                     
                     object.pro = [[followeeDic objectForKey:@"pro"]stringValue];
                     
                     object.name = [followeeDic objectForKey:@"name"];
                     
                     object.avatar_url = [followeeDic objectForKey:@"avatar_url"];
                     
                     object.shots_count = [[followeeDic objectForKey:@"shots_count"]stringValue];
                     
                     object.likes_count = [[followeeDic objectForKey:@"likes_count"]stringValue];
                     
                     object.followers_count = [[followeeDic objectForKey:@"followers_count"] stringValue];
                     
                     object.followings_count = [[followeeDic objectForKey:@"followings_count"] stringValue];
                     
                     if ( [[followeeDic objectForKey:@"location"]class] != [NSNull class])
                     {
                         object.location = [followeeDic objectForKey:@"location"];
                     }
                     
                     if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                     {
                         object.web = [[followeeDic objectForKey:@"links"] objectForKey:@"web"];
                     }
                     if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                     {
                         object.twitter = [[followeeDic objectForKey:@"links"] objectForKey:@"twitter"];
                     }
                     
                     x ++;
                     [self douma_save];
                 }
                 self.user.followers_lastmodified = lastModified;
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
         }];
        [operation start];
    }));
}






- (void)addView2Page:(UIScrollView *)scrollV count:(NSUInteger)pageCount
{
    for (int i = 1; i <= pageCount; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(scrollV.frame.size.width * (i-1), 0, scrollV.frame.size.width, scrollV.frame.size.height)];
        view.tag = i;
        view.userInteractionEnabled = YES;
        [self initPageView:view];
        [scrollV addSubview:view];
    }
    [scrollV setContentSize:CGSizeMake(scrollV.frame.size.width * pageCount, scrollV.frame.size.height)];
}

-(void) initPageView:(UIView *)view
{
    switch (view.tag) {
        case 1:
        {
            UICollectionViewFlowLayout *shotsCVFL = [[UICollectionViewFlowLayout alloc]init];
            shotsCVFL.itemSize = CGSizeMake((UI_SCREEN_WIDTH/2)-10, (UI_SCREEN_WIDTH/2)-10);
            shotsCVFL.sectionInset = UIEdgeInsetsMake(10, 6, 5, 6);
            shotsCVFL.minimumInteritemSpacing = 0;
            
            static NSString *shotsCellRI = @"shotsCellRI";
            UICollectionView *shotsCV = [[UICollectionView alloc]initWithFrame:view.frame collectionViewLayout:shotsCVFL];
            shotsCV.backgroundColor = BG_COLOR;
            shotsCV.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
            shotsCV.delegate = self;
            shotsCV.dataSource = self;
            shotsCV.scrollEnabled = NO;
            [shotsCV addFooterWithTarget:self action:@selector(shotsFootAction)];
            [shotsCV registerClass:[ShotsCell class] forCellWithReuseIdentifier:shotsCellRI];
            _shotsCV = shotsCV;
            
            
            
            UIImageView *headerV = [[UIImageView alloc]initWithFrame:CGRectMake(20, -20, 20, 20)];
            headerV.image = [UIImage imageNamed:@"shotsTag"];
            [shotsCV addSubview:headerV];

            UILabel *headerL = [[UILabel alloc]initWithFrame:CGRectMake(50, -25, view.frame.size.width, 30)];
            headerL.text =[NSString stringWithFormat:@"%@ shots",self.user.shots_count];
            headerL .textColor = RGBA(146, 146, 146, 1);
            headerL .textAlignment = NSTextAlignmentLeft;
            headerL .font = [UIFont fontWithName:@"Nexa Bold" size:11];
            [shotsCV addSubview:headerL ];

            
            
            [view addSubview:shotsCV];
         
            
            
            
        }
            break;
        case 2:
        {
            UICollectionViewFlowLayout *likesCFL = [[UICollectionViewFlowLayout alloc]init];
            likesCFL.itemSize = CGSizeMake((UI_SCREEN_WIDTH/2)-10, (UI_SCREEN_WIDTH/2)-10);
            likesCFL.sectionInset = UIEdgeInsetsMake(10, 6, 5, 6);
            likesCFL.minimumInteritemSpacing = 0;
            
            static NSString *likesCellRI = @"likesCellRI";
            UICollectionView *likesCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) collectionViewLayout:likesCFL];
            likesCV.backgroundColor = BG_COLOR;
            likesCV.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
            likesCV.delegate = self;
            likesCV.dataSource = self;
            likesCV.scrollEnabled = NO;
            [likesCV addFooterWithTarget:self action:@selector(likesFootAction)];
            [likesCV registerClass:[ShotsCell class] forCellWithReuseIdentifier:likesCellRI];
            _likesCV = likesCV;
            
            
            UIImageView *headerV = [[UIImageView alloc]initWithFrame:CGRectMake(20, -20, 20, 20)];
            headerV.image = [UIImage imageNamed:@"likesTag"];
            [likesCV addSubview:headerV];
            
            UILabel *headerL = [[UILabel alloc]initWithFrame:CGRectMake(50, -25, view.frame.size.width, 30)];
            headerL.text =[NSString stringWithFormat:@"%@ likes",self.user.likes_count];
            headerL .textColor = RGBA(146, 146, 146, 1);
            headerL .textAlignment = NSTextAlignmentLeft;
            headerL .font = [UIFont fontWithName:@"Nexa Bold" size:11];
            [likesCV addSubview:headerL ];
            
            
            
            
            
            [view addSubview:likesCV];

        }
            break;
        
        case 3:
        {
            UICollectionViewFlowLayout *followingVFL = [[UICollectionViewFlowLayout alloc]init];
            followingVFL.itemSize = CGSizeMake(UI_SCREEN_WIDTH-12, UI_SCREEN_WIDTH*5/32);
            followingVFL.sectionInset = UIEdgeInsetsMake(10, 6, 5, 6);
            followingVFL.minimumInteritemSpacing = 0;
            
            static NSString *followingCellRI = @"followingCellRI";
            UICollectionView *followingCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) collectionViewLayout:followingVFL];
            followingCV.backgroundColor = BG_COLOR;
            followingCV.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
            followingCV.delegate = self;
            followingCV.dataSource = self;
            followingCV.scrollEnabled = NO;
            [followingCV addFooterWithTarget:self action:@selector(followingFootAction)];
            [followingCV registerClass:[FollowCell class] forCellWithReuseIdentifier:followingCellRI];
            _followingCV = followingCV;
            
            
            UIImageView *headerV = [[UIImageView alloc]initWithFrame:CGRectMake(20, -20, 20, 20)];
            headerV.image = [UIImage imageNamed:@"usersTag"];
            [followingCV addSubview:headerV];
            
            UILabel *headerL = [[UILabel alloc]initWithFrame:CGRectMake(50, -25, view.frame.size.width, 30)];
            headerL.text =[NSString stringWithFormat:@"%@ following",self.user.followings_count];
            headerL .textColor = RGBA(146, 146, 146, 1);
            headerL .textAlignment = NSTextAlignmentLeft;
            headerL .font = [UIFont fontWithName:@"Nexa Bold" size:11];
            [followingCV addSubview:headerL ];

            [view addSubview:followingCV];

        
        }
            break;
        case 4:
        {
            UICollectionViewFlowLayout *followersVFL = [[UICollectionViewFlowLayout alloc]init];
            followersVFL.itemSize = CGSizeMake(UI_SCREEN_WIDTH-12, UI_SCREEN_WIDTH*5/32);
            followersVFL.sectionInset = UIEdgeInsetsMake(10, 6, 5, 6);
            followersVFL.minimumInteritemSpacing = 0;
            
            static NSString *followersCellRI = @"followersCellRI";
            UICollectionView *followersCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) collectionViewLayout:followersVFL];
            followersCV.backgroundColor = BG_COLOR;
            followersCV.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
            followersCV.delegate = self;
            followersCV.dataSource = self;
            followersCV.scrollEnabled = NO;
            [followersCV addFooterWithTarget:self action:@selector(followersFootAction)];
            [followersCV registerClass:[FollowCell class] forCellWithReuseIdentifier:followersCellRI];
            _followersCV = followersCV;
            
            
            UIImageView *headerV = [[UIImageView alloc]initWithFrame:CGRectMake(20, -20, 20, 20)];
            headerV.image = [UIImage imageNamed:@"usersTag"];
            [followersCV addSubview:headerV];
            
            UILabel *headerL = [[UILabel alloc]initWithFrame:CGRectMake(50, -25, view.frame.size.width, 30)];
            headerL.text =[NSString stringWithFormat:@"%@ followers",self.user.followers_count];
            headerL .textColor = RGBA(146, 146, 146, 1);
            headerL .textAlignment = NSTextAlignmentLeft;
            headerL .font = [UIFont fontWithName:@"Nexa Bold" size:11];
            [followersCV addSubview:headerL ];

            [view addSubview:followersCV];

        }
            break;
        case 5:
        {
            UIView *twitterV = [[UIView alloc]initWithFrame:CGRectMake(12, 12, view.frame.size.width-24, MIN(self.user.twitter.length, 1) * 50)];
            twitterV.backgroundColor = [UIColor whiteColor];
            twitterV.userInteractionEnabled = YES;
            twitterV.clipsToBounds = YES;
            [view addSubview:twitterV];
            

            
            UILabel *twitterL = [[UILabel alloc]initWithFrame:CGRectMake(25, 15, twitterV.frame.size.width, 20)];
            twitterL.font = [UIFont fontWithName:@"Nexa Bold" size:12];
            twitterL.textColor = [UIColor grayColor];
            twitterL.textAlignment = NSTextAlignmentLeft;
            twitterL.text = self.user.twitter;
            [twitterV addSubview:twitterL];
            
            
            
            
            UIImageView *twitterView  = [[UIImageView alloc]initWithFrame:CGRectMake(twitterV.frame.size.width - 50, 10, 30, 30)];
            twitterView.image = [UIImage imageNamed:@"twitter"];
            twitterView.userInteractionEnabled = YES;
            [twitterV addSubview:twitterView];
            
            
            
            UIView *webV = [[UIView alloc]initWithFrame:CGRectMake(12, twitterV.frame.size.height + twitterV.frame.origin.y + 2, twitterV.frame.size.width, MIN(self.user.web.length, 1) * 50)];
            webV.userInteractionEnabled = YES;
            webV.backgroundColor = [UIColor whiteColor];
            webV.clipsToBounds = YES;
            [view addSubview:webV];
            
            
            
            
            UILabel *webL = [[UILabel alloc]initWithFrame:CGRectMake(25, 15, webV.frame.size.width, 20)];
            webL.font = [UIFont fontWithName:@"Nexa Bold" size:12];
            webL.textColor = [UIColor grayColor];
            webL.textAlignment = NSTextAlignmentLeft;
            webL.text = self.user.web;
            [webV addSubview:webL];

            UIImageView *webView  = [[UIImageView alloc]initWithFrame:CGRectMake(webV.frame.size.width - 50, 10, 30, 30)];
            webView.image = [UIImage imageNamed:@"web"];
            webView.userInteractionEnabled = YES;
            [webV addSubview:webView];
            
        }
            break;
    }
  
    
}

#pragma mark -
#pragma mark FootAction

-(void)shotsFootAction
{
    BACK((^{
        NSLog(@"%@",shotsFootURL);
        
        NSInteger numbersItem = 1;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.shotsFRC sections][0];
        numbersItem = [sectionInfo numberOfObjects];
        if (numbersItem == [self.user.shots_count integerValue]) {
            MAIN(^{
                [_shotsCV footerEndRefreshing];
            });
            return;
        }

        
        
        NSURL *url = [NSURL URLWithString:[shotsFootURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSRange range = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1] substringToIndex:range.location-1];
            shotsFootURL = footstr;
            
            NSArray *array = (NSArray *)responseObject;
            for (NSDictionary *dic in array) {
                
                SHOTS *object = EntityObjects(@"SHOTS");
                
                object.shotsid = [[dic objectForKey:@"id"] stringValue];
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    object.shot_description = [dic objectForKey:@"description"];
                }
                
                object.title = [dic objectForKey:@"title"];
                object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                object.created_at = [dic objectForKey:@"created_at"];
                object.source = @"userShots";
                object.i = [NSNumber numberWithInteger:shotsN];
                
                object.user = self.user;
                NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                object.tags = tagsData;
                
                IMAGES*images = EntityObjects(@"IMAGES");
                object.images = images;
                
                if ([[[dic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                    images.hidpi = [[dic objectForKey:@"images"]objectForKey:@"hidpi"];
                }
                images.normal = [[dic objectForKey:@"images"]objectForKey:@"normal"];
                images.teaser = [[dic objectForKey:@"images"]objectForKey:@"teaser"];
                
                shotsN ++;
                
                [self douma_save];
                MAIN(^{
                    [_shotsCV footerEndRefreshing];
                });
            }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
         }];
        [operation start];
    }));
}

-(void)likesFootAction
{
    BACK((^{
        
        NSLog(@"%@",likesFootURL);
        
        NSInteger numbersItem = 1;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.likesFRC sections][0];
        numbersItem = [sectionInfo numberOfObjects];
        
        if (numbersItem == [self.user.likes_count integerValue]) {
            MAIN(^{
                [_likesCV footerEndRefreshing];
            });
            return;
        }
        
        NSURL *url = [NSURL URLWithString:[likesFootURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSRange range = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1] substringToIndex:range.location-1];
            likesFootURL = footstr;
            
            NSArray *array = (NSArray *)responseObject;
            
            for (NSDictionary *dic in array) {
                SHOTS *object = EntityObjects(@"SHOTS");
                NSDictionary *shotDic = [dic objectForKey:@"shot"];
                object.shotsid = [[shotDic objectForKey:@"id"] stringValue];
                
                if ([[shotDic objectForKey:@"description"]class] != [NSNull class]) {
                    object.shot_description = [shotDic objectForKey:@"description"];
                }
                object.title = [shotDic objectForKey:@"title"];
                object.likes_count = [[shotDic objectForKey:@"likes_count"]stringValue];
                object.comments_count = [[shotDic objectForKey:@"comments_count"]stringValue];
                object.views_count = [[shotDic objectForKey:@"views_count"]stringValue];
                object.attachments_count = [[shotDic objectForKey:@"attachments_count"]stringValue];
                object.created_at = [shotDic objectForKey:@"created_at"];
                object.source = @"userLikes";
                object.i = [NSNumber numberWithInteger:likesN];
                
                object.likedby = self.user;
                
                USER *user = EntityObjects(@"USER");
                object.user = user;
                
                user.avatar_url = [[shotDic objectForKey:@"user"]objectForKey:@"avatar_url"];
                user.name = [[shotDic objectForKey:@"user"]objectForKey:@"name"];
                user.shots_count = [[[shotDic objectForKey:@"user"]objectForKey:@"shots_count"]stringValue];
                user.likes_count = [[[shotDic objectForKey:@"user"]objectForKey:@"likes_count"]stringValue];
                user.followers_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followers_count"]stringValue];
                user.followings_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followings_count"]stringValue];
                
                if ( [[[shotDic objectForKey:@"user"]objectForKey:@"location"]class] != [NSNull class])
                {
                    user.location = [[shotDic objectForKey:@"user"]objectForKey:@"location"];
                }
                user.userid = [[[shotDic objectForKey:@"user"]objectForKey:@"id"]stringValue];
                
                NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                object.tags = tagsData;
                
                IMAGES*images = EntityObjects(@"IMAGES");
                object.images = images;
                
                if ([[[shotDic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                    images.hidpi = [[shotDic objectForKey:@"images"]objectForKey:@"hidpi"];
                }
                images.normal = [[shotDic objectForKey:@"images"]objectForKey:@"normal"];
                images.teaser = [[shotDic objectForKey:@"images"]objectForKey:@"teaser"];
            
                
                likesN ++;
                
                [self douma_save];
                
                MAIN(^{
                    [_likesCV footerEndRefreshing];
                });
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
         }];
        [operation start];
    }));

}
-(void)followingFootAction
{
    BACK((^{
        
        NSLog(@"%@",followingFootURL);
        
        NSInteger numbersItem = 1;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.followingFRC sections][0];
        numbersItem = [sectionInfo numberOfObjects];
        
        if (numbersItem == [self.user.followings_count integerValue]) {
            MAIN(^{
                [_followingCV footerEndRefreshing];
            });
            return;
        }
        
        NSURL *url = [NSURL URLWithString:[followingFootURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSRange range = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1] substringToIndex:range.location-1];
            followingFootURL = footstr;
            
            NSArray *array = (NSArray *)responseObject;
            
            for (NSDictionary *dic in array) {
                
                USER *object = EntityObjects(@"USER");
                
                NSDictionary *followeeDic = [dic objectForKey:@"followee"];
                
                object.followingby = self.user;
                
                object.source = @"userFollowing";
                
                object.i = [NSNumber numberWithInteger:followingN];
                
                object.userid = [[followeeDic objectForKey:@"id"] stringValue];
                
                object.pro = [[followeeDic objectForKey:@"pro"]stringValue];
                
                object.name = [followeeDic objectForKey:@"name"];
                
                object.avatar_url = [followeeDic objectForKey:@"avatar_url"];
                
                object.shots_count = [[followeeDic objectForKey:@"shots_count"]stringValue];
                
                object.likes_count = [[followeeDic objectForKey:@"likes_count"]stringValue];
                
                object.followers_count = [[followeeDic objectForKey:@"followers_count"] stringValue];
                
                object.followings_count = [[followeeDic objectForKey:@"followings_count"] stringValue];
                
                if ( [[followeeDic objectForKey:@"location"]class] != [NSNull class])
                {
                    object.location = [followeeDic objectForKey:@"location"];
                }
                
                if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                {
                    object.web = [[followeeDic objectForKey:@"links"] objectForKey:@"web"];
                }
                if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                {
                    object.twitter = [[followeeDic objectForKey:@"links"] objectForKey:@"twitter"];
                }
                
                
                followingN ++;
                
                [self douma_save];
                
                MAIN(^{
                    [_followingCV footerEndRefreshing];
                });
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
         }];
        [operation start];
    }));

}

-(void) followersFootAction
{
    BACK((^{
        
        
        NSInteger numbersItem = 1;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.followersFRC sections][0];
        numbersItem = [sectionInfo numberOfObjects];
        
        if (numbersItem == [self.user.followers_count integerValue]) {
            MAIN(^{
                [_followersCV footerEndRefreshing];
            });
            return;
        }
        NSLog(@"%@",followersFootURL);
        NSURL *url = [NSURL URLWithString:[followersFootURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSRange range = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1] substringToIndex:range.location-1];
            followersFootURL = footstr;
            
            NSArray *array = (NSArray *)responseObject;
            
            for (NSDictionary *dic in array) {
                
                USER *object = EntityObjects(@"USER");
                
                NSDictionary *followeeDic = [dic objectForKey:@"follower"];
                
                object.followersby = self.user;
                
                object.source = @"userFollowed";
                
                object.i = [NSNumber numberWithInteger:followersN];
                
                object.userid = [[followeeDic objectForKey:@"id"] stringValue];
                
                object.pro = [[followeeDic objectForKey:@"pro"]stringValue];
                
                object.name = [followeeDic objectForKey:@"name"];
                
                object.avatar_url = [followeeDic objectForKey:@"avatar_url"];
                
                object.shots_count = [[followeeDic objectForKey:@"shots_count"]stringValue];
                
                object.likes_count = [[followeeDic objectForKey:@"likes_count"]stringValue];
                
                object.followers_count = [[followeeDic objectForKey:@"followers_count"] stringValue];
                
                object.followings_count = [[followeeDic objectForKey:@"followings_count"] stringValue];
                
                if ( [[followeeDic objectForKey:@"location"]class] != [NSNull class])
                {
                    object.location = [followeeDic objectForKey:@"location"];
                }
                
                if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                {
                    object.web = [[followeeDic objectForKey:@"links"] objectForKey:@"web"];
                }
                if ( [[[followeeDic objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                {
                    object.twitter = [[followeeDic objectForKey:@"links"] objectForKey:@"twitter"];
                }
                
                
                followersN ++;
                
                [self douma_save];
                
                MAIN(^{
                    [_followersCV footerEndRefreshing];
                });
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
         }];
        [operation start];
    }));

}
#pragma mark - UICollectionViewDataSource

-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numbersItem = 1;
    
    if (collectionView == _shotsCV) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.shotsFRC sections][section];
        numbersItem = [sectionInfo numberOfObjects];
    }
    if (collectionView == _likesCV) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.likesFRC sections][section];
        numbersItem = [sectionInfo numberOfObjects];
    }
    if (collectionView == _followingCV) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.followingFRC sections][section];
        numbersItem = [sectionInfo numberOfObjects];
    }
    if (collectionView == _followersCV) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.followersFRC sections][section];
        numbersItem = [sectionInfo numberOfObjects];
    }

    return numbersItem;
}

-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


#pragma mark UICollectionViewDelegate

-(UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =nil;

    if (collectionView == _shotsCV) {
        static NSString *shotsCellRI = @"shotsCellRI";
        ShotsCell *shotsCell = (ShotsCell *)[_shotsCV dequeueReusableCellWithReuseIdentifier:shotsCellRI forIndexPath:indexPath];
        [self configureCell:shotsCell atIndexPath:indexPath forView:_shotsCV];
        cell = shotsCell;
    }
    if (collectionView == _likesCV) {
        static NSString *likesCellRI = @"likesCellRI";
        ShotsCell *likesCell = (ShotsCell *)[_likesCV dequeueReusableCellWithReuseIdentifier:likesCellRI forIndexPath:indexPath];
        [self configureCell:likesCell atIndexPath:indexPath forView:_likesCV];
        cell = likesCell;
    }
    if (collectionView == _followingCV) {
        static NSString *followingCellRI = @"followingCellRI";
        FollowCell *followingCell = (FollowCell *)[_followingCV dequeueReusableCellWithReuseIdentifier:followingCellRI forIndexPath:indexPath];
        [self configurefollowCell:followingCell atIndexPath:indexPath forView:_followingCV];
        cell = followingCell;
    }
    if (collectionView == _followersCV) {
        static NSString *followersCellRI = @"followersCellRI";
        FollowCell *followersCell = (FollowCell *)[_followersCV dequeueReusableCellWithReuseIdentifier:followersCellRI forIndexPath:indexPath];
        [self configurefollowCell:followersCell atIndexPath:indexPath forView:_followersCV];
        cell = followersCell;
    }

    return cell;
}

- (void)configureCell:(ShotsCell *)cell atIndexPath:(NSIndexPath *)indexPath forView:(UICollectionView *)collectionView
{
    SHOTS *object = nil;
    
    if (collectionView == _shotsCV) {
        SHOTS *shotsObject = [_shotsFRC objectAtIndexPath:indexPath];
        object = shotsObject;
    }
    if (collectionView == _likesCV) {
        SHOTS *likesObject = [_likesFRC objectAtIndexPath:indexPath];
        object = likesObject;
    }
    IMAGES *images = object.images;
    USER *user = object.user;
    
    NSURL *shotsURL = [NSURL URLWithString:images.teaser];
    NSURL *avatarURL = [NSURL URLWithString:user.avatar_url];
    NSRange range = [images.teaser rangeOfString:@"teaser"];
    NSString *str = [images.teaser substringFromIndex:range.location+6];
    
    [cell.shotsIV sd_setImageWithURL:shotsURL placeholderImage:[UIImage imageNamed:@"imagePlaceHolder"]];
    [cell.avatarIV sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"imagePlaceHolder"]];
    
    [cell.views_countL setText:object.views_count];
    [cell.comments_countL setText:object.comments_count];
    [cell.likes_countL setText:object.likes_count];
    if ([str isEqualToString:@".gif"]) {
        [cell.gifIV setImage:[UIImage imageNamed:@"gifImage"]];
    }
    else
    {
        [cell.gifIV setImage:nil];
    }
}


- (void)configurefollowCell:(FollowCell *)cell atIndexPath:(NSIndexPath *)indexPath forView:(UICollectionView *)collectionView
{
    USER *object = nil;
    if (collectionView == _followingCV) {
        USER *followingObject = [_followingFRC objectAtIndexPath:indexPath];
        object = followingObject;
        [cell.followB addTarget:self action:@selector(followAction1:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (collectionView == _followersCV) {
        USER *followingObject = [_followersFRC objectAtIndexPath:indexPath];
        object = followingObject;
        [cell.followB addTarget:self action:@selector(followAction2:) forControlEvents:UIControlEventTouchUpInside];
    }

    NSURL *avatarURL = [NSURL URLWithString:object.avatar_url];

    [cell.avatarV sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"imagePlaceHolder"]];
    [cell.userL setText:object.name];
    [cell.descriptionL setText:object.web];
    
    
 
}
-(void)followAction1:(UIButton *)button
{
    FollowCell *cell = (FollowCell*)button.superview;
    NSIndexPath *indexPath = [_followingCV indexPathForCell:cell];
    USER *following = [self.followingFRC objectAtIndexPath:indexPath];
    [self chooseFollow:following.userid :button];
    
}

-(void)followAction2:(UIButton *)button
{
    FollowCell *cell = (FollowCell*)button.superview;
    NSIndexPath *indexPath = [_followersCV indexPathForCell:cell];
    USER *follower = [self.followingFRC objectAtIndexPath:indexPath];
    [self chooseFollow:follower.userid:button];
    
}

-(void)chooseFollow:(NSString *)userID :(UIButton *)button
{
    if (button.selected == YES) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *bearerStr =[NSString stringWithFormat:@"Bearer %@",self.access_token];
        [manager.requestSerializer setValue:bearerStr forHTTPHeaderField:@"Authorization"];
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/follow",userID];
        [manager DELETE:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            button.selected = NO;
            button.backgroundColor = [UIColor clearColor];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            button.selected = YES;
            button.backgroundColor = [UIColor colorWithRed:224/255.0f green:24/255.0f blue:87/255.0f alpha:0.6];
        }];
        
    }
    else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *bearerStr =[NSString stringWithFormat:@"Bearer %@",self.access_token];
        [manager.requestSerializer setValue:bearerStr forHTTPHeaderField:@"Authorization"];
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/follow",userID ];
        [manager PUT:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            button.selected = YES;
            button.backgroundColor = [UIColor colorWithRed:224/255.0f green:24/255.0f blue:87/255.0f alpha:0.6];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            button.selected = NO;
            button.backgroundColor = [UIColor clearColor];
        }];
        
    }

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _shotsCV) {
        
        DetailVC *detailVC = [[DetailVC alloc]init];
        
        SHOTS *object = [_shotsFRC objectAtIndexPath:indexPath];
        
        NSManagedObjectID *objectID = [object objectID];
        
        detailVC.shotsID = [object valueForKey:@"shotsid"];
        
        detailVC.objectID = objectID;
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    if (collectionView == _likesCV) {
        DetailVC *detailVC = [[DetailVC alloc]init];
        
        SHOTS *object = [_likesFRC objectAtIndexPath:indexPath];
        
        NSManagedObjectID *objectID = [object objectID];
        
        detailVC.shotsID = [object valueForKey:@"shotsid"];
        
        detailVC.objectID = objectID;
        
        [self.navigationController pushViewController:detailVC animated:YES];

    }
    if (collectionView == _followingCV) {
        
        UserVC *userVC = [[UserVC alloc]init];
        USER *object = [_followingFRC objectAtIndexPath:indexPath];
        NSManagedObjectID *userObjectID = [object objectID];
        userVC.userID = object.userid;
        userVC.userObjectID = userObjectID;
        [self.navigationController pushViewController:userVC animated:YES];

    }
    if (collectionView == _followersCV) {
        
        UserVC *userVC = [[UserVC alloc]init];
        USER *object = [_followersFRC objectAtIndexPath:indexPath];
        NSManagedObjectID *userObjectID = [object objectID];
        userVC.userID = object.userid;
        userVC.userObjectID = userObjectID;
        [self.navigationController pushViewController:userVC animated:YES];        
    }
}



#pragma mark - UIScorllViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self changeAvatarView:scrollView];
    [self changeViewfor:scrollView];
    [self changeNav];
    [self controllScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float xx = _mainSV.contentOffset.x * (30 / self.view.frame.size.width) - 30;
    [_listSV scrollRectToVisible:CGRectMake(xx, 0, _listSV.frame.size.width, _listSV.frame.size.height) animated:YES];
}

#pragma mark UIScrollAction

-(void)controllScroll
{
  
    
    if (_bgSV.contentOffset.y > self.view.frame.size.width*25/32-63) {
        _shotsCV.scrollEnabled = YES;
        _likesCV.scrollEnabled = YES;
        _followingCV.scrollEnabled = YES;
        _followersCV.scrollEnabled = YES;
        _bgSV.scrollEnabled = NO;
    }
    
    
    
    if (_shotsCV.contentOffset.y < -30) {
        _shotsCV.scrollEnabled = NO;
        _bgSV.scrollEnabled = YES;

    }
    
    if (_likesCV.contentOffset.y < -30) {
        _likesCV.scrollEnabled = NO;
        _bgSV.scrollEnabled = YES;
    }
    
    if (_followingCV.contentOffset.y < -30) {
        _followingCV.scrollEnabled = NO;
        _bgSV.scrollEnabled = YES;

    }
    
    if (_followersCV.contentOffset.y < -30) {
        _followersCV.scrollEnabled = NO;
        _bgSV.scrollEnabled = YES;
        
    }

    
}


-(void)changeNav
{
    float y = _bgSV.contentOffset.y;
    float percent = y / 50;
    _navV.backgroundColor = RGBA(50, 50, 50, percent);
}


- (void)changeViewfor:(UIScrollView *)scrollView
{
    float x = _mainSV.contentOffset.x;
    
    float xx = x * (80 / self.view.frame.size.width);
    float startX = xx;
    
    int sT = (x)/_mainSV.frame.size.width + 1;
    if (sT <= 0)
    {
        return;
    }
    UIButton *btn = (UIButton *)[_listSV viewWithTag:sT];
    float percent = (startX - 80 * (sT - 1))/80;
    
    [self changeColorForButton:btn percent: (1 - percent)];
    
    if((int)xx%80 == 0)
        return;
    UIButton *btn2 = (UIButton *)[_listSV viewWithTag:sT + 1];
    
    [self changeColorForButton:btn2 percent:percent];
    
}

-(void)changeAvatarView:(UIScrollView * )scrollV
{
    float y = _bgSV.contentOffset.y;
    float viewX = self.view.frame.size.width;
    if( y < 0 )
    {
        _avatarBG.frame = CGRectMake(y, y, -2*y + scrollV.frame.size.width, -y + viewX*25/32+10);
        _blackIV.frame = CGRectMake(y, 0, -2*y + scrollV.frame.size.width, -y + viewX*25/32+10);
        _avatarIV.frame = CGRectMake(-2*y + viewX*3/8, -y + viewX/4 - 10, viewX/4, viewX/4);
        _userL.frame = CGRectMake(-2*y , -y + viewX/2 - 10, viewX, 40);
        _mapV.frame = CGRectMake(-2*y, -y + viewX/2 + 20, viewX, 30);
        _listSV.frame = CGRectMake(-2*y , -y + viewX/2 + 50, viewX, viewX*25/32-40-viewX/2);
    }
}

- (void)changeColorForButton:(UIButton *)btn percent:(float)percent
{
    btn.backgroundColor = RGBA(27, 27, 27, percent/10);
    [btn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6+0.4*(1-percent)] forState:UIControlStateNormal];
}

-(void)listButtonAction:(UIButton *)btn
{
    [_mainSV scrollRectToVisible:CGRectMake(_mainSV.frame.size.width * (btn.tag - 1), _mainSV.frame.origin.y, _mainSV.frame.size.width, _mainSV.frame.size.height) animated:YES];
}

#pragma mark - Nav

-(void)setNavigationBar
{
    
    UILabel *titlLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 0, 30, 40)];
    titlLabel.text = @"Player";
    titlLabel.textColor = [UIColor whiteColor];
    [titlLabel setFont:[UIFont fontWithName:@"Honduro" size:20]];
    self.navigationItem.titleView = titlLabel;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                imageView.hidden=YES;
            }
        }
    }
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *followItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    self.navigationItem.rightBarButtonItem = followItem;
    
}

#pragma -mark Other

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark View
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"touming"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;


    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                imageView.hidden=YES;
            }
        }
    }
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}
#pragma mark - NSFetchedResultsControllerDelegate


- (NSFetchedResultsController *)likesFRC
{
    if (_likesFRC != nil) {
        return _likesFRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SHOTS"inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *str = @"userLikes";
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(source = %@) AND (likedby = %@)",str,self.user];
    [fetchRequest setPredicate:cdt];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _likesFRC = aFetchedResultsController;
    
    NSError *error = nil;
    if (![_likesFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _likesFRC;
}
- (NSFetchedResultsController *)shotsFRC
{
    if (_shotsFRC != nil) {
        return _shotsFRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SHOTS"inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *str = @"userShots";
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(user = %@) AND (source = %@)",self.user,str];
    [fetchRequest setPredicate:cdt];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _shotsFRC = aFetchedResultsController;
    
    NSError *error = nil;
    if (![_shotsFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _shotsFRC;
}
- (NSFetchedResultsController *)followingFRC
{
    if (_followingFRC != nil) {
        return _followingFRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"USER"inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *str = @"userFollowing";
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(source = %@) AND (followingby = %@)",str,self.user];
    [fetchRequest setPredicate:cdt];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _followingFRC = aFetchedResultsController;
    
    NSError *error = nil;
    if (![_followingFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _followingFRC;
}

- (NSFetchedResultsController *)followersFRC
{
    if (_followersFRC != nil) {
        return _followersFRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"USER"inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *str = @"userFollowed";
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(source = %@) AND (followersby = %@)",str,self.user];
    [fetchRequest setPredicate:cdt];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _followersFRC = aFetchedResultsController;
    
    NSError *error = nil;
    if (![_followersFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _followersFRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
        _sectionChanges = [[NSMutableArray alloc] init];
    
        _shotsChanges = [[NSMutableArray alloc] init];
        _likesChanges = [[NSMutableArray alloc] init];
        _followingChanges = [[NSMutableArray alloc] init];
        _followersChanges = [[NSMutableArray alloc]init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    if (controller == _shotsFRC) {
        [_shotsChanges addObject:change];
    }
    if (controller == _likesFRC) {
        [_likesChanges addObject:change];

    }
    if (controller == _followingFRC) {
        [_followingChanges addObject:change];
        
    }
    if (controller == _followersFRC) {
        [_followersChanges addObject:change];
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == _shotsFRC) {
        [_shotsCV performBatchUpdates:^{
            
            for (NSDictionary *change in _shotsChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [_shotsCV insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_shotsCV deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_shotsCV reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [_shotsCV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            _sectionChanges = nil;
            _shotsChanges = nil;
        }];

    }
    if (controller == _likesFRC) {
        [_likesCV performBatchUpdates:^{
            
            for (NSDictionary *change in _likesChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [_likesCV insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_likesCV deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_likesCV reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [_likesCV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            _sectionChanges = nil;
            _likesChanges = nil;


        }];
        
    }
    if (controller == _followingFRC) {
        [_followingCV performBatchUpdates:^{
            
            for (NSDictionary *change in _followingChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [_followingCV insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_followingCV deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_followingCV reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [_followingCV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            _sectionChanges = nil;
            _followingChanges = nil;

        }];
        
    }
    if (controller == _followersFRC) {
        [_followersCV performBatchUpdates:^{
            
            for (NSDictionary *change in _followersChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [_followersCV insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_followersCV deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_followersCV reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [_followersCV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            _sectionChanges = nil;
            _followersChanges = nil;
        }];
        
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
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)isRootViewController
{
    return (self == self.navigationController.viewControllers.firstObject);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self isRootViewController]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

@end
