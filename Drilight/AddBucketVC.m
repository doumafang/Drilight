
//define
#import "DEFINE.h"

//vc
#import "AddBucketVC.h"
#import "AddBucketCell.h"

//delegate
#import "AppDelegate.h"

//model
#import "BUCKETS.h"
#import "USER.h"
#import "IMAGES.h"

//frame
#import "AFNetworking.h"

@interface AddBucketVC ()<UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate,UITextViewDelegate>
{
    NSMutableArray *_bucketsChanges;
    NSMutableArray *_sectionChanges;
    
    NSMutableArray *_selectedChanges;
    
    
    UIButton *_bucketB;
    BOOL _animating;
    
    UIView *_bgV;
    UIButton *_addButton;
    UIButton *_cancelButton;
    UIButton *_createButton;
    UIImageView *_doneV;
    
    UILabel *_nameLengthL;
    UILabel *_descriptionLengthL;
    
    UITextView *_nameTV;
    UITextView *_descriptionTV;
}

@property (nonatomic) NSFetchedResultsController *bucketsFRC;
@property UICollectionView *bucketsV;
@property UIView *writeV;
@property NSString *access_token;
@property AppDelegate *myDelegate;
@property USER *user;
@property SHOTS *shots;

@end

@implementation AddBucketVC

#pragma mark -
#pragma mark ClassAction

+ (AddBucketVC *)mainAdd
{
    @synchronized(self)
    {
        static AddBucketVC *mainAdd = nil;
        if (mainAdd == nil)
        {
            mainAdd = [[self alloc] init];
        }
        return mainAdd;
    }
    
}

+(void)addBucketShow:(SHOTS *)shots inButton:(UIButton *)button

{
    [[AddBucketVC mainAdd] show:shots];
    [[AddBucketVC mainAdd] bucketButton:button];
}

#pragma mark

-(void)bucketButton :(UIButton *)button
{
    _bucketB = button;
}

- (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
}
#pragma mark - Frame

- (CGRect)onscreenFrame
{
    return [UIScreen mainScreen].bounds;
}

- (CGRect)offscreenFrame
{
    CGRect frame = [self onscreenFrame];
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortrait:
            frame.origin.y = frame.size.height;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            frame.origin.y = -frame.size.height;
            break;
        default:
            break;
    }
    return frame;
}

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)show :(SHOTS *)shots
{
    self.shots = shots;
    
    if (!_animating && self.view.superview == nil)
    {
        [AddBucketVC mainAdd].view.frame = [self offscreenFrame];
        [[self mainWindow] addSubview:[AddBucketVC mainAdd].view];
        
        _animating = YES;
        
        [AddBucketVC mainAdd].view.frame = [self onscreenFrame];
    }
}


- (void)hideGuide
{

    _animating = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(guideHidden)];
    _bgV.frame = CGRectMake(SCREENX / 8, SCREENY, SCREENX*3/4, SCREENX*4/3);
    [UIView commitAnimations];
}

- (void)guideHidden
{
    _animating = NO;
    [AddBucketVC mainAdd].view.frame = [self offscreenFrame];
    [[AddBucketVC mainAdd].view removeFromSuperview];

    
}


#pragma mark -
#pragma mark View

-(void)viewWillAppear:(BOOL)animated
{
    for (NSIndexPath *indexPath in _selectedChanges) {
        [_bucketsV deselectItemAtIndexPath:indexPath animated:NO];
    }
    _selectedChanges = nil;
    if ( _selectedChanges == nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissDone" object:nil];
    }
    _bgV.frame = CGRectMake(SCREENX/8, SCREENY, SCREENX*3/4, SCREENY - SCREENX /2);
    
    [UIView animateWithDuration:0.3 animations:^{
        _bgV.frame = CGRectMake(SCREENX/8, SCREENX /4, SCREENX*3/4, SCREENY - SCREENX /2);

    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.05f animations:^{
                _bgV.frame = CGRectMake(SCREENX/8, SCREENX /3, SCREENX*3/4, SCREENY - SCREENX /2);

            }];
        }
    }];

}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAdd) name:@"dismissAdd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissDone) name:@"dismissDone" object:nil];

  
    UIButton *alphaB = [[UIButton alloc]initWithFrame:self.view.frame];
    alphaB.backgroundColor = RGBA(0, 0, 0, 0.5);
    [alphaB addTarget:self action:@selector(touchAlphaV:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alphaB];
    
    if (!_bgV) {
        UIView *bgV = [[UIView alloc]initWithFrame:CGRectMake(SCREENX/ 8, SCREENY, SCREENX*3/4, SCREENY - SCREENX /2)];
        bgV.backgroundColor = BG_COLOR;
        bgV.layer.masksToBounds = YES;
        bgV.layer.cornerRadius = 6;
        _bgV = bgV;

    }
    [alphaB addSubview:_bgV];
    
    [UIView animateWithDuration:0.05f animations:^{
        _bgV.frame = CGRectMake(SCREENX/8, SCREENX /3, SCREENX*3/4, SCREENY - SCREENX /2);
    }];

    float itemX = SCREENX*3/4;
    
    UILabel *inforL = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, itemX- 20, 20)];
    inforL.text = @"Add this shot to a bucket";
    inforL.font = [UIFont fontWithName:@"Nexa Bold" size:13];
    inforL.textAlignment = NSTextAlignmentLeft;
    inforL.textColor = RGBA(85, 85, 85, 1);
    [_bgV addSubview:inforL];
    
    UIView *lineOne = [[UIView alloc]initWithFrame:CGRectMake(15, inforL.frame.size.height + inforL.frame.origin.y, itemX-30, 0.5f)];
    lineOne.backgroundColor = [UIColor grayColor];
    [_bgV addSubview:lineOne];
    
    if (!_bucketsV) {
        
        UICollectionViewFlowLayout *bucketVFL = [[UICollectionViewFlowLayout alloc]init];
        bucketVFL.itemSize = CGSizeMake(itemX-40, itemX/4);
        bucketVFL.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        bucketVFL.minimumInteritemSpacing = 20;
        bucketVFL.minimumLineSpacing = 20;
        
        UICollectionView *bucketV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, lineOne.frame.origin.y+1, itemX, itemX * 4/3) collectionViewLayout:bucketVFL];
        bucketV.delegate = self;
        bucketV.dataSource = self;
        bucketV.backgroundColor = BG_COLOR;
        bucketV.scrollEnabled = YES;
        bucketV.showsHorizontalScrollIndicator = NO;
        bucketV.showsVerticalScrollIndicator = YES;
        bucketV.allowsMultipleSelection = YES;
        static NSString *addBucketCellRI = @"addBucketCellRI";
        [bucketV registerClass:[AddBucketCell class] forCellWithReuseIdentifier:addBucketCellRI];
        _bucketsV = bucketV;
        
    }
    [_bgV addSubview:_bucketsV];

    
    UIView *lineTwo = [[UIView alloc]initWithFrame:CGRectMake(15, _bucketsV.frame.size.height + _bucketsV.frame.origin.y , itemX-30, 0.5f)];
    lineTwo.backgroundColor = [UIColor grayColor];
    [_bgV addSubview:lineTwo];
    


    if (!_addButton) {
        UIButton *addB = [[UIButton alloc]initWithFrame:CGRectMake(itemX/4, lineTwo.frame.origin.y + 15 , itemX/2, 30)];
        addB.backgroundColor = RGBA(241, 92, 149, 1);
        addB.layer.masksToBounds = YES;
        addB.layer.cornerRadius = addB.frame.size.height/2;
        [addB addTarget:self action:@selector(addBucketAction:) forControlEvents:UIControlEventTouchUpInside];
        [addB setTitle:@"Create a new bucket" forState:UIControlStateNormal];
        [addB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addB.titleLabel.font = [UIFont fontWithName:@"Nexa Bold" size:10];
       _addButton  = addB;

    }
    [_bgV addSubview:_addButton];

    
    
    
    [self bucketAction];
    
    if (! _doneV) {
        UIImageView *doneV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yesDone"]];
        doneV.userInteractionEnabled = YES;
        doneV.frame = CGRectMake(itemX*5/12, _bgV.frame.size.height*16/18, itemX/6, itemX/6);
        _doneV = doneV;
        [_doneV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doneAction)]];
        
    }

    
}


#pragma mark -
#pragma mark ButtonAction
-(void)doneAction
{
    for (NSIndexPath * indexPath in _selectedChanges) {
        BUCKETS *bucket = [self.bucketsFRC objectAtIndexPath:indexPath];
        NSString *bucketId = bucket.bucketID;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *bearerStr =[NSString stringWithFormat:@"Bearer %@",self.access_token];
        [manager.requestSerializer setValue:bearerStr forHTTPHeaderField:@"Authorization"];
        NSDictionary *kv = @{@"shot_id":self.shots.shotsid};
        NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/buckets/%@/shots",bucketId];
        [manager PUT:str parameters:kv success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self bucketAction];
            [self touchAlphaV:nil];
            _selectedChanges = nil;
            if (! _bucketB.selected == YES) {
                _bucketB.selected = YES;
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];

        
    }
}


-(void)addBucketAction:(UIButton *)button
{
    
    UIView *bgV = button.superview;
    UILabel *inforL = [bgV.subviews objectAtIndex:0];
    inforL.text = @"Create a new bucket";
    float itemX = bgV.frame.size.width;
    
    if (!_cancelButton) {
        UIButton *cancelB = [[UIButton alloc]initWithFrame:CGRectMake(30, button.frame.origin.y, button.frame.size.width * 3/4, button.frame.size.height)];
        [cancelB setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelB.backgroundColor = RGBA(191, 191, 191, 1);
        cancelB.layer.cornerRadius = cancelB.frame.size.height/2;
        cancelB.titleLabel.font = [UIFont fontWithName:@"Nexa Bold" size:10];
        cancelB.layer.masksToBounds = YES;
        [cancelB addTarget:self action:@selector(cancelBucketAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton = cancelB;
    }
    [bgV addSubview:_cancelButton];

    
    if (!_createButton) {
        UIButton *createB = [[UIButton alloc]initWithFrame:CGRectMake(40 + _cancelButton.frame.size.width , button.frame.origin.y, button.frame.size.width * 3/4, button.frame.size.height)];
        [createB setTitle:@"Create" forState:UIControlStateNormal];
        [createB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        createB.backgroundColor = RGBA(241, 92, 149, 1);
        createB.layer.cornerRadius = createB.frame.size.height / 2;
        createB.titleLabel.font = [UIFont fontWithName:@"Nexa Bold" size:10];
        createB.layer.masksToBounds = YES;
        [createB addTarget:self action:@selector(createBucketAction) forControlEvents:UIControlEventTouchUpInside];
        _createButton = createB;
    }
    
    [bgV addSubview:_createButton];

    if (!self.writeV)
    {
        UIView *writeV = [[UIView alloc]initWithFrame:_bucketsV.frame];
        
        UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 50, 20)];
        nameL.text = @"Name";
        nameL.textAlignment = NSTextAlignmentLeft;
        nameL.font = [UIFont fontWithName:@"Nexa Bold" size:11];
        nameL.textColor = inforL.textColor;
        [writeV addSubview:nameL];
        
        UILabel *nameLengthL = [[UILabel alloc]initWithFrame:CGRectMake(0, nameL.frame.origin.y, itemX-20, 20)];
        nameLengthL.text = @"32";
        nameLengthL.textColor = nameL.textColor;
        nameLengthL.textAlignment = NSTextAlignmentRight;
        nameLengthL.font = [UIFont fontWithName:@"Nexa Bold" size:10];
        [writeV addSubview:nameLengthL];
        _nameLengthL = nameLengthL;
        
        
        
        UITextView *nameTV = [[UITextView alloc]initWithFrame:CGRectMake(20, nameL.frame.size.height + nameL.frame.origin.y, itemX - 40, 20)];
        nameTV.delegate = self;
        nameTV.textAlignment = NSTextAlignmentLeft;
        nameTV.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
        nameTV.backgroundColor = [UIColor whiteColor];
        nameTV.dataDetectorTypes = UIDataDetectorTypeAll;
        nameTV.scrollEnabled = NO;
        nameTV.textColor = [UIColor blackColor];
        nameTV.font = [UIFont systemFontOfSize:11];
        [writeV addSubview:nameTV];
        _nameTV = nameTV;
        
        UILabel *descpitionL = [[UILabel alloc]initWithFrame:CGRectMake(20, nameTV.frame.size.height + nameTV.frame.origin.y ,70, 20)];
        descpitionL.text = @"Description";
        descpitionL.textAlignment = NSTextAlignmentLeft;
        descpitionL.font = [UIFont fontWithName:@"Nexa Bold" size:11];
        descpitionL.textColor = inforL.textColor;
        [writeV addSubview:descpitionL];
        
        
        UILabel *descripitionLengthL = [[UILabel alloc]initWithFrame:CGRectMake(0, descpitionL.frame.origin.y, itemX-20, 20)];
        descripitionLengthL.text = @"160";
        descripitionLengthL.textColor = nameL.textColor;
        descripitionLengthL.textAlignment = NSTextAlignmentRight;
        descripitionLengthL.font = [UIFont fontWithName:@"Nexa Bold" size:10];
        [writeV addSubview:descripitionLengthL];
        _descriptionLengthL = descripitionLengthL;

        
        UITextView *descriptionTV = [[UITextView alloc]initWithFrame:CGRectMake(20, descpitionL.frame.size.height + descpitionL.frame.origin.y, itemX - 40, itemX - 40)];
        descriptionTV.delegate = self;
        descriptionTV.textAlignment = NSTextAlignmentLeft;
        descriptionTV.backgroundColor = [UIColor whiteColor];
        descriptionTV.dataDetectorTypes = UIDataDetectorTypeAll;
        descriptionTV.textColor = [UIColor blackColor];
        descriptionTV.font = [UIFont systemFontOfSize:11];
        [writeV addSubview:descriptionTV];
        _descriptionTV = descriptionTV;
        
        
        
        self.writeV = writeV;
    }
    [bgV addSubview:self.writeV];


    [_addButton removeFromSuperview];
    [_bucketsV removeFromSuperview];
    
}


-(void)cancelBucketAction:(UIButton *)button
{
    UIView *bgV = button.superview;
    UILabel *inforL = [bgV.subviews objectAtIndex:0];
    inforL.text = @"Add this shot to a bucket";

    [bgV addSubview:_bucketsV];
    [bgV addSubview:_addButton];
    [_createButton removeFromSuperview];
    [_cancelButton removeFromSuperview];
    [_writeV removeFromSuperview];
}

-(void)createBucketAction
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *bearerStr =[NSString stringWithFormat:@"Bearer %@",self.access_token];
    [manager.requestSerializer setValue:bearerStr forHTTPHeaderField:@"Authorization"];
    NSDictionary *kv = @{@"name":_nameTV.text,@"description":_descriptionTV.text};

    NSString *str = [NSString stringWithFormat:@"https://api.dribbble.com/v1/buckets"];
    [manager POST:str parameters:kv success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self cancelBucketAction:_cancelButton];
        [self bucketAction];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           }];

}

#pragma mark backgroundAction
-(void)touchAlphaV:(UIButton *)button
{
    [[AddBucketVC mainAdd] hideGuide];
}

#pragma mark -
#pragma mark UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL yesOrNo = YES;
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger length = toBeString.length;
    
    if (textView == _nameTV) {
        
        NSInteger restLength = 32 - length;
        if (restLength < 10 ) {
            _nameLengthL.textColor = RGBA(241, 92, 149, 1);

        }
        
        if (restLength > 10 ) {
        _nameLengthL.textColor = RGBA(85, 85, 85, 1);
        
        }
        
        if (restLength >= 0) {
            yesOrNo = YES;
        }
        
        if (restLength < 0) {
            yesOrNo = NO;
            restLength = 0;
        }
        
        NSString *str = [NSString stringWithFormat:@"%lu",(long)restLength];
        _nameLengthL.text = str;
    }
    else
    {
        NSInteger restLength = 160 - length;
        
        if (restLength < 20 ) {
            _descriptionLengthL.textColor = RGBA(241, 92, 149, 1);
            
        }
        
        if (restLength > 20 ) {
            _descriptionLengthL.textColor = RGBA(85, 85, 85, 1);
            
        }
        
        if (restLength >= 0) {
            yesOrNo = YES;
        }
        
        if (restLength < 0) {
            yesOrNo = NO;
            restLength = 0;
        }
        
        NSString *str = [NSString stringWithFormat:@"%lu",(long)restLength];
        _descriptionLengthL.text = str;

    }
    return yesOrNo;
}

#pragma mark -
#pragma mark NSNotificationCenter

-(void)dismissAdd
{
    UIView *bgV = _addButton.superview;
    
    [_addButton removeFromSuperview];
    [bgV addSubview:_doneV];
}

-(void)dismissDone
{
    UIView *bgV = _doneV.superview;
    
    [_doneV removeFromSuperview];
    [bgV addSubview:_addButton];
}

#pragma mark -
#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_selectedChanges) {
        _selectedChanges = [[NSMutableArray alloc]init];

    }
    [_selectedChanges addObject:indexPath];
  
    if (_selectedChanges.count != 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissAdd" object:nil];
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedChanges removeObject:indexPath];

    if (_selectedChanges.count == 0| _selectedChanges == nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissDone" object:nil];
    }
}




-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.bucketsFRC sections][section];
    return [sectionInfo numberOfObjects];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return [[self.bucketsFRC sections] count];
}

#pragma mark UICollectionViewDatasource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *addBucketCellRI = @"addBucketCellRI";
    AddBucketCell *cell = (AddBucketCell *)[collectionView dequeueReusableCellWithReuseIdentifier:addBucketCellRI forIndexPath:indexPath];
    [self configureCell:cell forindexPath:indexPath forView:collectionView];
        return cell;
    
}
-(void)configureCell:(AddBucketCell *)cell forindexPath:(NSIndexPath *)indexPath forView:(UICollectionView *)collectionView
{
    
    BUCKETS *buckets = [self.bucketsFRC objectAtIndexPath:indexPath];
    NSArray  *array = [buckets.shots allObjects];
    
    if (array.count != 0) {
        SHOTS *shots = [array objectAtIndex:array.count - 1];
        NSURL *url = [NSURL URLWithString:shots.images.teaser];
        [cell.imageV setImageWithURL:url placeholderImage:[UIImage imageNamed:@"shotsPlaceHolder"]];
    }
    else
    {
        [cell.imageV setImage:[UIImage imageNamed:@"shotsPlaceHolder"]];

    }
    [cell.bucketNameL setText:buckets.name];
    [cell.bucketNumberL setText:[NSString stringWithFormat:@"%@ shots",buckets.shots_count]];
}

#pragma mark -
#pragma mark CellAction
-(void)shotsForBuckets:(BUCKETS *)buckets
{
    BACK((^{
        NSString *str = [[NSString stringWithFormat:@"https://api.dribbble.com/v1/buckets/%@/shots?access_token=%@",buckets.bucketID,self.access_token]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:str];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *array = (NSArray *)responseObject;
            // one shots
            for (NSDictionary *dic in array) {
                SHOTS *shots = EntityObjects(@"SHOTS");
                IMAGES*images = EntityObjects(@"IMAGES");
                if ([[[dic objectForKey:@"images"]objectForKey:@"hidpi"]class] != [NSNull class]) {
                    images.hidpi = [[dic objectForKey:@"images"]objectForKey:@"hidpi"];
                }
                
                images.normal = [[dic objectForKey:@"images"]objectForKey:@"normal"];
                images.teaser = [[dic objectForKey:@"images"]objectForKey:@"teaser"];
                shots.images = images;
                shots.buckets = buckets;
                [self douma_save];

            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        [operation start];
    }));
}

-(void)bucketAction
{
    BACK((^{
        NSString *str = [[NSString stringWithFormat:@"https://api.dribbble.com/v1/user/buckets?access_token=%@&per_page=20",self.access_token]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *lastModified = [[operation.response allHeaderFields] valueForKey:@"Last-Modified"];
            if ([self.user.bucket_lastmodified isEqualToString:lastModified]) {
                return ;
            }
            self.user.bucket_lastmodified = lastModified;
            
            [self.user removeBuckets:self.user.buckets];
            [self douma_save];
            
            NSArray *array = (NSArray *)responseObject;
            for (NSDictionary *dic in array) {
                BUCKETS *buckets = EntityObjects(@"BUCKETS");
                
                buckets.user = self.user;
                buckets.name = [dic objectForKey:@"name"];
                buckets.shots_count  = [[dic objectForKey:@"shots_count"]stringValue];
                buckets.bucketID = [[dic objectForKey:@"id"]stringValue];
                if (!([[dic objectForKey:@"description"] class] == [NSNull class])) {
                    buckets.bucketdescription = [dic objectForKey:@"description"];
                }
                [self shotsForBuckets:buckets];
                [self douma_save];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        [operation start];
    }));
}

#pragma mark -
#pragma mark BucketsFRC

-(NSFetchedResultsController *)bucketsFRC
{
    if (_bucketsFRC != nil) {
        return _bucketsFRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BUCKETS" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //关系

    NSPredicate * cdt = [NSPredicate predicateWithFormat:@"user = %@",[self fetcheUserInfor]];
    [fetchRequest setPredicate:cdt];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.myDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"self.buckets"];
    aFetchedResultsController.delegate = self;
    self.bucketsFRC = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.bucketsFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _bucketsFRC;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _sectionChanges = [[NSMutableArray alloc] init];
    _bucketsChanges = [[NSMutableArray alloc] init];
    
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
    [_bucketsChanges addObject:change];
        
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_bucketsV performBatchUpdates:^{
        
        for (NSDictionary *change in _bucketsChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [_bucketsV insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [_bucketsV deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [_bucketsV reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [_bucketsV moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _bucketsChanges = nil;
    }];
        

}


-(USER *)fetcheUserInfor
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"USER" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSString *str = @"self";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source = %@", str];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userid"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.myDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.user = [fetchedObjects objectAtIndex:0];
    
    
    
    
    [self douma_save];
    
    return self.user;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
