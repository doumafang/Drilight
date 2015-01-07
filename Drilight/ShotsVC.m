
#import "DEFINE.h"

#import "ShotsVC.h"
#import "SHOTS.h"
#import "IMAGES.h"
#import "USER.h"
#import "ShotsCell.h"
#import "DetailVC.h"


#import "MJRefresh.h"
#import "REFrostedViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"

static NSString * POPULAR_REStr = @"POPULAR_RE";
static NSString * footerAPIStr = @"https://api.dribbble.com/v1/shots?per_page=10&page=2&access_token=1e58a8e4da9a4b31d829aab25cc10a207d84fc4dc6bdcfb884d15c914240c181";
static NSInteger numbersOfItems = 10;

@interface ShotsVC ()<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}

@property AppDelegate *myDelegate;

@property NSString *access_token;

@property NSString *headerLastModified;
@property UICollectionView *CV;


@property (nonatomic)  NSFetchedResultsController *fRC;
@end

@implementation ShotsVC


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"%@",NSHomeDirectory());

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"refresh" object:nil];


    self.view.backgroundColor = BG_COLOR;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];

    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UI_NAVIGATION_BAR_HEIGHT, UI_NAVIGATION_BAR_HEIGHT)];
    
    titleLabel.text = @"Popular";
    
    titleLabel.textColor = [UIColor whiteColor];
    
    [titleLabel setFont:[UIFont fontWithName:@"Honduro" size:20]];
    
    self.navigationItem.titleView = titleLabel;
    
    titleLabel.userInteractionEnabled = YES;
    
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"leftBBI"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    
    self.navigationItem.leftBarButtonItem = leftBBI;
    

    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    
    UICollectionViewFlowLayout *popularVFL = [[UICollectionViewFlowLayout alloc]init];
    popularVFL.itemSize = CGSizeMake((UI_SCREEN_WIDTH/2)-9, (UI_SCREEN_WIDTH/2)-9);
    popularVFL.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    popularVFL.minimumInteritemSpacing = 3;
    popularVFL.minimumLineSpacing = 6;

    
    UICollectionView *popularCV = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:popularVFL];
    popularCV.backgroundColor = BG_COLOR;
    
    popularCV.delegate = self;
    
    popularCV.dataSource = self;
    
    [popularCV registerClass:[ShotsCell class] forCellWithReuseIdentifier:POPULAR_REStr];
    
    [popularCV addHeaderWithTarget:self action:@selector(headerNetAction)];
    [popularCV addFooterWithTarget:self action:@selector(footerNetAction)];
    

    if (self.access_token) {
        
        [popularCV headerBeginRefreshing];
    }

    [self.view addSubview:popularCV];
    
    self.CV = popularCV;
    
    self.view = self.CV;

}
#pragma mark NetworkAction




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
            NSInteger x = 0;
        
            [self deleteEntityObject:@"SHOTS"];
            
            NSRange footrange = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                 substringToIndex:footrange.location-1];
            
            footerAPIStr = footstr;
            
            numbersOfItems = 10;
            
            for (NSDictionary *dic in array) {
                
                SHOTS *object = EntityObjects(@"SHOTS");
                
                object.shotsid = [[dic objectForKey:@"id"] stringValue];
                
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    
                    object.shot_description = [dic objectForKey:@"description"];
                    
                }
                object.source = @"popular";
                
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
    BACK((^{
        NSURL *url = [NSURL URLWithString:[footerAPIStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSArray *array = (NSArray *)responseObject;
            
            NSRange range = [[[operation.response allHeaderFields]valueForKey:@"Link"] rangeOfString:@">"];
            
            NSString *footstr = [[[[operation.response allHeaderFields]valueForKey:@"Link"] substringFromIndex:1]
                                 substringToIndex:range.location-1];
            footerAPIStr = footstr;

            for (NSDictionary *dic in array) {
                
                SHOTS *object = EntityObjects(@"SHOTS");
                
                object.shotsid = [[dic objectForKey:@"id"] stringValue];
                
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    
                    object.shot_description = [dic objectForKey:@"description"];
                    
                }
                
                object.source = @"popular";
                
                object.title = [dic objectForKey:@"title"];
                
                object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                
                object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                
                object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                
                object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                
                object.created_at = [dic objectForKey:@"created_at"];
                
                object.i = [NSNumber numberWithInteger:numbersOfItems];
                
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

                numbersOfItems ++;
                
                [self douma_save];
                
            }
            MAIN((^{
                
                [self.CV footerEndRefreshing];
                
            }));
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"ERROR_%@:%@",error,[error userInfo]);
            
        }];
        [operation start];
    }));

}
#pragma mark UICollectionDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetailVC *detailVC = [[DetailVC alloc]init];
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = [object objectID];
    detailVC.shotsID = [object valueForKey:@"shotsid"];
    detailVC.objectID = objectID;
    
    [self.navigationController pushViewController:detailVC animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
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

-(UICollectionViewCell * )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShotsCell *shotsCell = (ShotsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:POPULAR_REStr forIndexPath:indexPath];
    [self configureCell:shotsCell atIndexPath:indexPath];
    return shotsCell;
}

- (void)configureCell:(ShotsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    IMAGES *images = object.images;
    USER *user = object.user;
    NSURL *shotsURL = [NSURL URLWithString:[images valueForKey:@"teaser"]];
    NSURL *avatarURL = [NSURL URLWithString:[user valueForKey:@"avatar_url"]];
    NSRange range = [[images valueForKey:@"teaser"] rangeOfString:@"teaser"];
    NSString *str = [[images valueForKey:@"teaser"] substringFromIndex:range.location+6];
    
    [cell.shotsIV sd_setImageWithURL:shotsURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
    [cell.avatarIV sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatarPlaceHolder"]];
    [cell.views_countL setText:[object valueForKey:@"views_count"]];
    [cell.comments_countL setText:[object valueForKey:@"comments_count"]];
    [cell.likes_countL setText:[object valueForKey:@"likes_count"]];
    
    if ([str isEqualToString:@".gif"]) {
        [cell.gifIV setImage:[UIImage imageNamed:@"gifImage"]];
    }
    else
    {
        [cell.gifIV setImage:nil];
    }
}
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
    NSString *str = @"popular";
    
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"source = %@",str];
    [fetchRequest setPredicate:cdt];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"popular"];
    
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


#pragma mark DefineAction




-(void)leftAction
{
    [self.frostedViewController presentMenuViewController];
    
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



-(void)refresh
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"]) {
        self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
        [self.CV headerBeginRefreshing];
    }
}
@end
