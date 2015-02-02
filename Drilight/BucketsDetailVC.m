//define
#import "DEFINE.h"

//VC+delegate
#import "BucketsDetailVC.h"
#import "AppDelegate.h"
#import "DetailVC.h"
#import "UserVC.h"


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
#import "ShotsCell.h"

@interface BucketsDetailVC ()<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}
@property NSString *access_token;
@property AppDelegate *myDelegate;
@property BUCKETS *buckets;
@property UICollectionView *shotsV;
@property (nonatomic)  NSFetchedResultsController *fRC;

@end

@implementation BucketsDetailVC


#pragma mark View

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
    
    
    NSError *objectError = nil;
    NSManagedObject *bucketsObject = [self.myDelegate.managedObjectContext existingObjectWithID:self.bucketsObjectID error:&objectError];
    _buckets = (BUCKETS *)bucketsObject;
    
    [self headerNetAction];

    [self setNav];
    [self setShotsV];
}

#pragma mark -
#pragma mark Nav
-(void)setNav
{
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UI_NAVIGATION_BAR_HEIGHT, UI_NAVIGATION_BAR_HEIGHT)];
    titleLabel.text = self.buckets.name;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    self.navigationItem.titleView = titleLabel;
    titleLabel.userInteractionEnabled = YES;
    
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBBI;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}


-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark ShotsV
-(void)setShotsV
{
    
    UIFont *font = [UIFont fontWithName:@"Nexa Bold" size:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [_buckets.bucketdescription boundingRectWithSize:CGSizeMake(SCREENX - 32, 10000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;


    UICollectionViewFlowLayout *shotsVFL = [[UICollectionViewFlowLayout alloc]init];
    shotsVFL.itemSize = CGSizeMake((SCREENX/2)-9, (SCREENX/2)-9);
    shotsVFL.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    shotsVFL.minimumInteritemSpacing = 3;
    shotsVFL.headerReferenceSize = CGSizeMake(SCREENX, size.height + 60);
    shotsVFL.minimumLineSpacing = 6;
    
    static NSString * shotsRE = @"shotsRE";
    UICollectionView *shotsV = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:shotsVFL];
    shotsV.backgroundColor = BG_COLOR;
    shotsV.delegate = self;
    shotsV.dataSource = self;
    [shotsV registerClass:[ShotsCell class] forCellWithReuseIdentifier:shotsRE];
    [shotsV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    
    
    [shotsV addHeaderWithTarget:self action:@selector(test)];
    [shotsV addFooterWithTarget:self action:nil];
    shotsV.header.frame = CGRectMake(0, - 20 , SCREENX, 50);
    shotsV.drilight.bounds = CGRectMake(0, 0, 0, 0);
    
    
    _shotsV = shotsV;
    self.view = shotsV;
    
    

    
}
-(void)test
{
    [self performSelector:@selector(test1) withObject:self afterDelay:1.0f];
}
-(void)test1
{
    [self.shotsV headerEndRefreshing];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView

{
    [self drilightBeginScale:scrollView.contentOffset.y];
}


-(void)drilightBeginScale :(CGFloat )y
{
    CGFloat drilightX = _shotsV.frame.origin.x;
    CGFloat drilightY = _shotsV.frame.origin.y;
    if (y <= 0) {
        float scaleX = MIN(30, -y );
        _shotsV.drilight.bounds = CGRectMake(drilightX, drilightY, scaleX, scaleX);
    }

    
}

#pragma mark -
#pragma mark NetAction

-(void)headerNetAction
{
    BACK((^{
        
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/buckets/%@/shots?access_token=%@",self.buckets.bucketID,self.access_token];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *array = (NSArray *)responseObject;
            
            
             NSString *lastModified = [[operation.response allHeaderFields]objectForKey:@"Last-Modified"];
            if (self.buckets.shots_lastmodified != lastModified) {
                

                NSInteger x = 0;
                
                for (NSDictionary *dic in array) {
                    SHOTS *object = EntityObjects(@"SHOTS");
                    object.shotsid = [[dic objectForKey:@"id"] stringValue];
                    
                    if ([[dic objectForKey:@"description"]class] != [NSNull class]) {
                        object.shot_description = [dic objectForKey:@"description"];
                    }
                    object.source = @"buckets";
                    object.title = [dic objectForKey:@"title"];
                    object.likes_count = [[dic objectForKey:@"likes_count"]stringValue];
                    object.comments_count = [[dic objectForKey:@"comments_count"]stringValue];
                    object.views_count = [[dic objectForKey:@"views_count"]stringValue];
                    object.attachments_count = [[dic objectForKey:@"attachments_count"]stringValue];
                    object.created_at = [dic objectForKey:@"created_at"];
                    object.i = [NSNumber numberWithInteger:x];
                    object.buckets = self.buckets;
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
                    self.buckets.shots_lastmodified = lastModified;
                    [self douma_save];
                    
                }
                MAIN(^{
                    [self.shotsV headerEndRefreshing];
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"ERROR%@:%@",error,[error userInfo]);
            MAIN(^{
                [self.shotsV headerEndRefreshing];
            });
            
        }];
        
        [operation start];
        
    }));
    
}




#pragma mark -
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


#pragma mark UICollectionViewDelegate

-(UICollectionViewCell * )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * shotsRE = @"shotsRE";
    ShotsCell *shotsCell = (ShotsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:shotsRE forIndexPath:indexPath];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

    UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
    
    UIFont *font = [UIFont fontWithName:@"Nexa Bold" size:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [_buckets.bucketdescription boundingRectWithSize:CGSizeMake(SCREENX - 32, 10000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    
    UIImageView *headerV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5 , 25, 25)];
    headerV.image = [UIImage imageNamed:@"shotsTag"];
    [reusableview addSubview:headerV];

    UILabel *headerL = [[UILabel alloc]initWithFrame:CGRectMake(40, 5  , SCREENX, 30)];
    headerL.text =[NSString stringWithFormat:@"%@ shots",self.buckets.shots_count];
    headerL.textColor = RGBA(146, 146, 146, 1);
    headerL.textAlignment = NSTextAlignmentLeft;
    headerL.font = [UIFont fontWithName:@"Nexa Bold" size:11];
    [reusableview addSubview:headerL];


    UIView *descriptionV = [[UIView alloc]initWithFrame:CGRectMake(10, 40 , SCREENX - 20,MIN(size.height, 1)* (size.height+20))];
    descriptionV.backgroundColor = [UIColor whiteColor];
    descriptionV.layer.masksToBounds = YES;
    descriptionV.layer.cornerRadius = 2.0f;
    descriptionV.clipsToBounds = YES;
    [reusableview addSubview:descriptionV];

    UILabel *descriptionL = [[UILabel alloc]initWithFrame:CGRectMake(6, 10, SCREENX - 32, size.height + 2)];
    descriptionL.text = _buckets.bucketdescription;
    descriptionL.textColor = RGBA(85, 85, 85, 1);
    descriptionL.font = font;
    descriptionL.textAlignment = NSTextAlignmentLeft;
    [descriptionV addSubview:descriptionL];

    
    return reusableview;
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
    NSIndexPath *indexPath = [self.shotsV indexPathForCell:cell];
    UserVC *userVC = [[UserVC alloc]init];
    
    SHOTS *object = [self.fRC objectAtIndexPath:indexPath];
    USER *user = object.user;
    
    NSManagedObjectID *objectID = [user objectID];
    userVC.userID = user.userid;
    userVC.userObjectID = objectID;
    
    [self.navigationController pushViewController:userVC animated:YES];
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate


- (NSFetchedResultsController *)fRC
{
    
    if (_fRC != nil) {
        return _fRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SHOTS" inManagedObjectContext:self.myDelegate.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"i" ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //属性
    NSString *str = @"buckets";

    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"(buckets = %@) AND (source = %@)",self.buckets,str];
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
    [self.shotsV performBatchUpdates:^{
        
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.shotsV insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.shotsV deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.shotsV reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.shotsV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
