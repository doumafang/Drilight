
//define
#import "DEFINE.h"

//VC+delegate
#import "BucketsDetailVC.h"
#import "AppDelegate.h"
#import "UserVC.h"
#import "BucketsVC.h"



//model
#import "BUCKETS.h"
#import "IMAGES.h"
#import "USER.h"
#import "SHOTS.h"

//frame
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "MJRefresh.h"

//view
#import "BucketsCell.h"


@interface BucketsVC ()<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}
@property NSString *access_token;
@property AppDelegate *myDelegate;
@property UICollectionView *bucketsV;
@property USER *user;
@property (nonatomic)  NSFetchedResultsController *fRC;

@end

@implementation BucketsVC


-(void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                imageView.hidden = NO;
            }
        }
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BG_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.access_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
    self.myDelegate = [[UIApplication sharedApplication]delegate];

    NSError *objectError= nil;
    NSManagedObject *userObject = [self.myDelegate.managedObjectContext existingObjectWithID:self.userObjectID error:&objectError];
    self.user = (USER *)userObject;

    
    [self setNav];
    [self setBucketsV];
    [self getBuckets];
    
    
}
#pragma mark -
#pragma mark Nav

-(void)setNav
{
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UI_NAVIGATION_BAR_HEIGHT, UI_NAVIGATION_BAR_HEIGHT)];
    titleLabel.text = @"Buckets";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    self.navigationItem.titleView = titleLabel;
    titleLabel.userInteractionEnabled = YES;
    
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBBI;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}

#pragma mark -
#pragma mark BucketsV
-(void)setBucketsV
{
    
    UICollectionViewFlowLayout *bucketsVFL = [[UICollectionViewFlowLayout alloc]init];
    bucketsVFL.itemSize = CGSizeMake((SCREENX/2)-9, ((SCREENX-20)/2)-4+42);
    bucketsVFL.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    bucketsVFL.minimumInteritemSpacing = 0;
    
    static NSString *bucketsRI = @"bucketsCellRI";
    UICollectionView *bucketsV = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:bucketsVFL];
    bucketsV.backgroundColor = BG_COLOR;
    bucketsV.delegate = self;
    bucketsV.dataSource = self;
    bucketsV.scrollEnabled = YES;
    [bucketsV registerClass:[BucketsCell class] forCellWithReuseIdentifier:bucketsRI];
    
    
    [bucketsV addHeaderWithTarget:self action:@selector(test)];
    [bucketsV addFooterWithTarget:self action:nil];
    
    
    bucketsV.header.frame = CGRectMake(0, - 20 , SCREENX, 50);
    bucketsV.drilight.bounds = CGRectMake(0, 0, 0, 0);
    
    _bucketsV = bucketsV;
    self.view = bucketsV;
    
}


-(void)test
{
    [self performSelector:@selector(test1) withObject:self afterDelay:1.0f];
}
-(void)test1
{
    [self.bucketsV headerEndRefreshing];
}

-(void)getBuckets
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/users/%@/buckets?access_token=%@",self.userID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *array = (NSArray *)responseObject;
            for (NSDictionary *dic in array) {
                BUCKETS *buckets = EntityObjects(@"BUCKETS");
                buckets.user = self.user;
                if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                    buckets.bucketdescription = [dic objectForKey:@"description"];
                }
                buckets.source = @"buckets";
                buckets.bucketID = [[dic objectForKey:@"id"]stringValue];
                buckets.name = [dic objectForKey:@"name"];
                buckets.shots_count = [[dic objectForKey:@"shots_count"]stringValue];
                
                [self douma_save];
                [self bucketsShots:buckets];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation start];
        
    }));
    
}

-(void)bucketsShots:(BUCKETS *)buckets
{
    BACK((^{
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/buckets/%@/shots?access_token=%@",buckets.bucketID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *array = (NSArray *)responseObject;
            NSInteger x = 0;
            for (NSDictionary *dic  in array) {
                SHOTS *object = EntityObjects(@"SHOTS");
                NSDictionary *shotDic = dic;
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
                object.i = [NSNumber numberWithInteger:x];
                object.buckets = buckets;
                object.source = @"page_user";
                USER *user = EntityObjects(@"USER");
                object.user = user;
                
                user.avatar_url = [[shotDic objectForKey:@"user"]objectForKey:@"avatar_url"];
                user.name = [[shotDic objectForKey:@"user"]objectForKey:@"name"];
                user.shots_count = [[[shotDic objectForKey:@"user"]objectForKey:@"shots_count"]stringValue];
                user.likes_count = [[[shotDic objectForKey:@"user"]objectForKey:@"likes_count"]stringValue];
                user.followers_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followers_count"]stringValue];
                user.followings_count = [[[shotDic objectForKey:@"user"]objectForKey:@"followings_count"]stringValue];
                user.buckets_count = [[[shotDic objectForKey:@"user"]objectForKey:@"buckets_count"]stringValue];
                user.bio = [[shotDic objectForKey:@"user"]objectForKey:@"bio"];
                if ( [[[shotDic objectForKey:@"user"]objectForKey:@"location"]class] != [NSNull class])
                {
                    user.location = [[shotDic objectForKey:@"user"]objectForKey:@"location"];
                }
                user.userid = [[[shotDic objectForKey:@"user"]objectForKey:@"id"]stringValue];
                
                
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
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation start];
        
    }));
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bucketsCellRI = @"bucketsCellRI";
    BucketsCell *bucketsCell = (BucketsCell *)[_bucketsV dequeueReusableCellWithReuseIdentifier:bucketsCellRI forIndexPath:indexPath];
    [self configurebucketsCell:bucketsCell atIndexPath:indexPath forView:_bucketsV];
    return bucketsCell;
}

-(void)configurebucketsCell:(BucketsCell *)cell atIndexPath:(NSIndexPath *)indexPath forView:(UICollectionView *)collectionView
{
    
    BUCKETS *buckets = [self.fRC objectAtIndexPath:indexPath];
    NSArray *array = [buckets.shots allObjects];
    
    if (array.count == 1) {
        
        SHOTS *mainShots = [array objectAtIndex:0];
        NSURL *mainURL = [NSURL URLWithString:mainShots.images.teaser];
        [cell.mainIV sd_setImageWithURL:mainURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        
        
    }
    if (array.count == 2) {
        
        SHOTS *mainShots = [array objectAtIndex:0];
        NSURL *mainURL = [NSURL URLWithString:mainShots.images.teaser];
        
        SHOTS *fShots = [array objectAtIndex:1];
        NSURL *fURL = [NSURL URLWithString:fShots.images.teaser];
        
        [cell.mainIV sd_setImageWithURL:mainURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        [cell.fIV sd_setImageWithURL:fURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        
        
        
    }
    if (array.count == 3) {
        
        SHOTS *mainShots = [array objectAtIndex:0];
        NSURL *mainURL = [NSURL URLWithString:mainShots.images.teaser];
        
        SHOTS *fShots = [array objectAtIndex:1];
        NSURL *fURL = [NSURL URLWithString:fShots.images.teaser];
        
        SHOTS *sShots = [array objectAtIndex:2];
        NSURL *sURL = [NSURL URLWithString:sShots.images.teaser];
        
        [cell.mainIV sd_setImageWithURL:mainURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        
        [cell.fIV sd_setImageWithURL:fURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        [cell.sIV sd_setImageWithURL:sURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        
        
    }
    if (array.count >= 4) {
        
        SHOTS *mainShots = [array objectAtIndex:0];
        NSURL *mainURL = [NSURL URLWithString:mainShots.images.teaser];
        
        SHOTS *fShots = [array objectAtIndex:1];
        NSURL *fURL = [NSURL URLWithString:fShots.images.teaser];
        
        SHOTS *sShots = [array objectAtIndex:2];
        NSURL *sURL = [NSURL URLWithString:sShots.images.teaser];
        
        SHOTS *tShots = [array objectAtIndex:3];
        NSURL *tURL = [NSURL URLWithString:tShots.images.teaser];
        
        
        [cell.mainIV sd_setImageWithURL:mainURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        [cell.fIV sd_setImageWithURL:fURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        [cell.sIV sd_setImageWithURL:sURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        [cell.tIV sd_setImageWithURL:tURL placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
        
        
    }
    cell.bucketsNumber.text = [NSString stringWithFormat:@"%@ shots",buckets.shots_count];
    cell.buctetsName .text = buckets.name;
    
    
}


-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fRC sections][section];
    return [sectionInfo numberOfObjects];
}

-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return [[self.fRC sections] count];
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BucketsDetailVC *bucketsDetailVC = [[BucketsDetailVC alloc]init];
    BUCKETS *buckets = [_fRC objectAtIndexPath:indexPath];
    NSManagedObjectID *bucketsObjectID = [buckets objectID];
    bucketsDetailVC.bucketsID = buckets.bucketID;
    bucketsDetailVC.bucketsObjectID = bucketsObjectID;
    [self.navigationController pushViewController:bucketsDetailVC animated:YES];

}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate


- (NSFetchedResultsController *)fRC
{
    
    if (_fRC != nil) {
        return _fRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BUCKETS" inManagedObjectContext:self.myDelegate.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //属性
    NSString *str = @"buckets";
    
    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(user = %@) AND (source = %@)",self.user,str];
    [fetchRequest setPredicate:cdt];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    [self.bucketsV performBatchUpdates:^{
        
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.bucketsV insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.bucketsV deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.bucketsV reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.bucketsV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
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


-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
