//define
#import "DEFINE.h"

//VC
#import "ShotsVC.h"
#import "DetailVC.h"
#import "UserVC.h"


//Model
#import "SHOTS.h"
#import "IMAGES.h"
#import "USER.h"

//views
#import "ShotsCell.h"

//frame
#import "MJRefresh.h"
#import "REFrostedViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"


@interface ShotsVC ()<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}

@property AppDelegate *myDelegate;
@property NSString *access_token;
@property NSUserDefaults *userDefaults;
@property UICollectionView *CV;
@property (nonatomic)  NSFetchedResultsController *fRC;

@end

@implementation ShotsVC
#pragma mark -
#pragma mark View

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                imageView.hidden=NO;
            }
        }
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"refresh" object:nil];

    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.access_token = [self.userDefaults objectForKey:@"access_token"];


    self.view.backgroundColor = BG_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    [self setNav];
    [self setCV];
    
    NSLog(@"%@",NSHomeDirectory());



}

#pragma mark -
#pragma mark CV

-(void) setCV
{
    UICollectionViewFlowLayout *popularVFL = [[UICollectionViewFlowLayout alloc]init];
    popularVFL.itemSize = CGSizeMake((SCREENX/2)-9, (SCREENX/2)-9);
    popularVFL.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    popularVFL.minimumInteritemSpacing = 3;
    popularVFL.minimumLineSpacing = 6;
    
    UICollectionView *popularCV = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:popularVFL];
    popularCV.backgroundColor = BG_COLOR;
    popularCV.delegate = self;
    popularCV.dataSource = self;
    
    static NSString * POPULAR_REStr = @"POPULAR_RE";

    [popularCV registerClass:[ShotsCell class] forCellWithReuseIdentifier:POPULAR_REStr];
    [popularCV addHeaderWithTarget:self action:@selector(headerNetAction)];
    [popularCV addFooterWithTarget:self action:@selector(footerNetAction)];
    _CV = popularCV;
    popularCV.drilight.bounds = CGRectMake(0, 0, 0, 0);
    
    
    if (self.access_token) {
        [popularCV headerBeginRefreshing];
    }
    
    self.view = self.CV;

}

#pragma mark -
#pragma mark SetNav

-(void)setNav
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UI_NAVIGATION_BAR_HEIGHT, UI_NAVIGATION_BAR_HEIGHT)];
    titleLabel.text = @"Popular";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.userInteractionEnabled = YES;
    [titleLabel setFont:[UIFont fontWithName:@"Honduro" size:20]];
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
    [self.frostedViewController presentMenuViewController];
}


#pragma mark -
#pragma mark NetAction

-(void)headerNetAction
{
    BACK((^{

        NSString *str = [POPULAR_API stringByAppendingString:self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *array = (NSArray *)responseObject;
            
            NSString *lastModified = [[operation.response allHeaderFields] valueForKey:@"Last-Modified"];
            NSString *oldModified = [self.userDefaults objectForKey:@"POPULAR_OLD"];
            
            if ([lastModified isEqualToString:oldModified]) {
                
                MAIN(^{
                    [self.CV headerEndRefreshing];
                });
                
                return;
            }
            
            [self.userDefaults setObject:lastModified forKey:@"POPULAR_OLD"];
            
            NSInteger x = 0;
            
            [self deleteEntityObject:@"SHOTS"];
        
            for (NSDictionary *dic in array) {
                
                SHOTS *object = EntityObjects(@"SHOTS");
                object.shotsid = [[dic objectForKey:@"id"] stringValue];
                
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    object.shot_description = [dic objectForKey:@"description"];
                }
                
                object.source = @"POPULAR";
                object.title = [dic objectForKey:@"title"];
                object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                object.created_at = [dic objectForKey:@"created_at"];
                object.i = [NSNumber numberWithInteger:x];

                NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                object.tags = tagsData;
                
                IMAGES*images = EntityObjects(@"IMAGES");
                object.images = images;
                
                if ([[[dic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                    images.hidpi = [[dic objectForKey:@"images"]objectForKey:@"hidpi"];
                }
                
                images.normal = [[dic objectForKey:@"images"]objectForKey:@"normal"];
                images.teaser = [[dic objectForKey:@"images"]objectForKey:@"teaser"];
                
                USER *user = EntityObjects(@"USER");
                object.user = user;
                user.shots_count = [[[dic objectForKey:@"user"]objectForKey:@"shots_count"]stringValue];
                user.buckets_count = [[[dic objectForKey:@"user"]objectForKey:@"buckets_count"]stringValue];
                user.likes_count = [[[dic objectForKey:@"user"]objectForKey:@"likes_count"]stringValue];
                user.followers_count = [[[dic objectForKey:@"user"]objectForKey:@"followers_count"]stringValue];
                user.bio = [[dic objectForKey:@"user"]objectForKey:@"bio"];
                user.followings_count = [[[dic objectForKey:@"user"]objectForKey:@"followings_count"]stringValue];
                user.avatar_url = [[dic objectForKey:@"user"]objectForKey:@"avatar_url"];
                user.name = [[dic objectForKey:@"user"]objectForKey:@"name"];
                user.pro = [[[dic objectForKey:@"user"]objectForKey:@"pro"]stringValue];
                
                if ( [[[dic objectForKey:@"user"]objectForKey:@"location"]class] != [NSNull class])
                {
                    user.location = [[dic objectForKey:@"user"]objectForKey:@"location"];
                }
                
                if ( [[[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                {
                    user.web = [[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"web"];
                }
                if ( [[[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                {
                    user.twitter = [[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"twitter"];
                }
                user.userid = [[[dic objectForKey:@"user"]objectForKey:@"id"]stringValue];
                
                x ++;
                
                [self douma_save];
                
            }
            MAIN(^{
                [self.CV headerEndRefreshing];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"ERROR%@:%@",error,[error userInfo]);
            MAIN(^{
                [self.CV headerEndRefreshing];
            });
            
        }];
        
        [operation start];
        
   }));
    
}


-(void)footerNetAction
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fRC sections][0];
    
    __block NSInteger itmes = [sectionInfo numberOfObjects];
    NSInteger numbers = itmes/12+1;
    
    NSString *footAPIStr = [NSString stringWithFormat:@"https://api.dribbble.com/v1/shots?access_token=%@&page=%lu",self.access_token,numbers];
    
    BACK((^{
        NSURL *url = [NSURL URLWithString:[footAPIStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSArray *array = (NSArray *)responseObject;
            
            for (NSDictionary *dic in array) {
                
                
                SHOTS *object = EntityObjects(@"SHOTS");
                object.shotsid = [[dic objectForKey:@"id"] stringValue];
                
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    object.shot_description = [dic objectForKey:@"description"];
                }
                
                object.source = @"POPULAR";
                object.title = [dic objectForKey:@"title"];
                object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                object.created_at = [dic objectForKey:@"created_at"];
                object.i = [NSNumber numberWithInteger:itmes];
                
                IMAGES*images = EntityObjects(@"IMAGES");
                object.images = images;
                
                NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:[dic objectForKey:@"tags"]];
                object.tags = tagsData;

                if ([[[dic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                    images.hidpi = [[dic objectForKey:@"images"]objectForKey:@"hidpi"];
                }
                
                images.normal = [[dic objectForKey:@"images"]objectForKey:@"normal"];
                images.teaser = [[dic objectForKey:@"images"]objectForKey:@"teaser"];
                
                USER *user = EntityObjects(@"USER");
                object.user = user;
                
                user.avatar_url = [[dic objectForKey:@"user"]objectForKey:@"avatar_url"];
                user.name = [[dic objectForKey:@"user"]objectForKey:@"name"];
                user.shots_count = [[[dic objectForKey:@"user"]objectForKey:@"shots_count"]stringValue];
                user.bio = [[dic objectForKey:@"user"]objectForKey:@"bio"];
                user.likes_count = [[[dic objectForKey:@"user"]objectForKey:@"likes_count"]stringValue];
                user.buckets_count = [[[dic objectForKey:@"user"]objectForKey:@"buckets_count"]stringValue];
                user.followers_count = [[[dic objectForKey:@"user"]objectForKey:@"followers_count"]stringValue];
                user.followings_count = [[[dic objectForKey:@"user"]objectForKey:@"followings_count"]stringValue];
                user.pro = [[[dic objectForKey:@"user"]objectForKey:@"pro"]stringValue];
                
                if ( [[[dic objectForKey:@"user"]objectForKey:@"location"]class] != [NSNull class])
                {
                    user.location = [[dic objectForKey:@"user"]objectForKey:@"location"];
                }
                
                if ( [[[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"web"] class] != [NSNull class])
                {
                    user.web = [[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"web"];
                }
                if ( [[[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"twitter"] class] != [NSNull class])
                {
                    user.twitter = [[[dic objectForKey:@"user"]objectForKey:@"links"] objectForKey:@"twitter"];
                }
                user.userid = [[[dic objectForKey:@"user"]objectForKey:@"id"]stringValue];

                itmes ++ ;
                
                [self douma_save];
                
            }
            MAIN((^{
                
                [self.CV footerEndRefreshing];
                
            }));
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"ERROR_%@:%@",error,[error userInfo]);
            MAIN((^{
                
                [self.CV footerEndRefreshing];
                
            }));
            
        }];
        [operation start];
    }));

}

#pragma mark -
#pragma mark UICollectionDelegate

-(UICollectionViewCell * )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * POPULAR_REStr = @"POPULAR_RE";
    
    ShotsCell *shotsCell = (ShotsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:POPULAR_REStr forIndexPath:indexPath];
    [self configureCell:shotsCell atIndexPath:indexPath];
    return shotsCell;
}

- (void)configureCell:(ShotsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    IMAGES *images = object.images;
    USER *user = object.user;
    NSURL *shotsURL = [NSURL URLWithString:images.teaser];
    NSURL *avatarURL = [NSURL URLWithString:user.avatar_url];
    NSRange range = [images.teaser rangeOfString:@"teaser"];
    NSString *str = [images.teaser substringFromIndex:range.location+6];
    
    [cell.shotsIV sd_setImageWithURL:shotsURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
    [cell.avatarIV sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatarPlaceHolder"]];
    [[cell.avatarIV.gestureRecognizers objectAtIndex:0] addTarget:self action:@selector(avatarAction:)];
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

#pragma mark UICollectionDataSource

-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fRC sections][section];
    return [sectionInfo numberOfObjects];
}

-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{

    return [[self.fRC sections] count];

}


#pragma mark -
#pragma mark Click


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetailVC *detailVC = [[DetailVC alloc]init];
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = [object objectID];
    detailVC.shotsID = object.shotsid;
    detailVC.objectID = objectID;
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

-(void)avatarAction:(UIGestureRecognizer *)GR
{
    UIImageView *view = (UIImageView *)GR.view;
    ShotsCell *cell = (ShotsCell *) view.superview;
    NSIndexPath *indexPath = [self.CV indexPathForCell:cell];
    UserVC *userVC = [[UserVC alloc]init];
    
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    USER *user = object.user;
    
    NSManagedObjectID *objectID = [user objectID];
    userVC.userID = user.userid;
    userVC.userObjectID = objectID;
    
    [self.navigationController pushViewController:userVC animated:YES];
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self drilightBeginScale:scrollView.contentOffset.y];
}



-(void)drilightBeginScale :(CGFloat )y
{
    CGFloat drilightX = _CV.frame.origin.x;
    CGFloat drilightY = _CV.frame.origin.y;
    float scaleX = MIN(30, -y);
    _CV.drilight.bounds = CGRectMake(drilightX, drilightY, scaleX, scaleX);
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate


- (NSFetchedResultsController *)fRC
{

    if (_fRC != nil) {
        return _fRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SHOTS"inManagedObjectContext:self.myDelegate.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //属性
    NSString *str = @"POPULAR";
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"source = %@",str];
    [fetchRequest setPredicate:cdt];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"POPULAR"];
    
    aFetchedResultsController.delegate = self;
    
    _fRC = aFetchedResultsController;

    NSError *error = nil;
    
    if (![self.fRC performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
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
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.CV performBatchUpdates:^{

        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.CV insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.CV deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.CV reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.CV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
    }];
}

-(void)deleteEntityObject: (NSString *)enityName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:enityName inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.myDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects) {
        [self.myDelegate.managedObjectContext deleteObject:object];
    }
    [self douma_save];
}

-(void)douma_save
{
    NSError *error = nil;
    if (![self.myDelegate.managedObjectContext save:&error])
    {
        NSLog(@"Error%@:%@",error,[error userInfo]);
    }
    
}
#pragma mark -
#pragma mark Other


-(void)refresh
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"]) {
        self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
        NSLog(@"%@",self.access_token);
        [self.CV headerBeginRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
