
#import "SelectVC.h"
#import "DEFINE.h"

@interface SelectVC ()
{
    UIBarButtonItem  * _barButton;
    UIView *_selectV;
}

@end
@implementation SelectVC
#pragma mark -
#pragma mark ClassAction


+ (SelectVC *)mainSelect
{
    @synchronized(self)
    {
        static SelectVC *mainSelect = nil;
        if (mainSelect == nil)
        {
            mainSelect = [[self alloc] init];
        }
        return mainSelect;
    }
    
}

+(void)selectShow :(UIBarButtonItem *)barButtonItem

{
    [[SelectVC mainSelect] show:barButtonItem ];
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

- (void)show :(UIBarButtonItem *)barButtonItem 
{
    _barButton = barButtonItem;
    if (self.view.superview == nil)
    {
        [SelectVC mainSelect].view.frame = [self onscreenFrame];
        [[self mainWindow] addSubview:[SelectVC mainSelect].view];
        
        
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

- (void)hideView
{

    [UIView animateWithDuration:0.2f animations:^{
    _selectV.frame = CGRectMake(0, SCREENY, SCREENX,SCREENX/4);


    }completion:^(BOOL finished){
        [[SelectVC mainSelect].view removeFromSuperview];

    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *alphaB = [[UIButton alloc]initWithFrame:self.view.frame];
    alphaB.backgroundColor = RGBA(0, 0, 0, 0.5);
    [alphaB addTarget:self action:@selector(touchAlpha) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alphaB];
    
    UIView *selectV = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENY , SCREENX,SCREENX/4)];
    selectV.backgroundColor = [UIColor whiteColor];
    selectV.alpha = 1.0f;
    [alphaB addSubview:_selectV = selectV];
    
    
    NSArray *array = @[@"popularity",@"views",@"comments",@"recent"];
    float sumX = 0;
    for (NSInteger i = 0 ; i < array.count; i ++ ) {
        UIButton *button = [[UIButton alloc]init];

        UIFont *font = [UIFont fontWithName:@"Nexa Bold" size:12];

        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        CGSize size = [array[i] boundingRectWithSize:CGSizeMake(1000, 20) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        button.tag = i;
        
        
        
        
        [button addTarget:self action:@selector(chooseSort:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(sumX ,0, SCREENX/4, SCREENX/4);

        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:RGBA(50, 50, 50, 1) forState:UIControlStateNormal];
        [button setTitleColor:RGBA(241, 92, 149, 1) forState:UIControlStateHighlighted];
        NSString *imageName = [NSString stringWithFormat:@"%@_1",array[i]];
        NSString *imageHighlightName = [NSString stringWithFormat:@"%@_2",array[i]];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imageHighlightName] forState:UIControlStateHighlighted ];
        
        float imageX = button.imageView.frame.size.width;
        float titleX = size.width;

        [button setImageEdgeInsets:UIEdgeInsetsMake(imageX/2,(SCREENX/4 - imageX)/2, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(imageX*5/3,  - imageX + (SCREENX/4 - titleX)/2, 0, 0)];
        [button.titleLabel setFont:font];
        
        [selectV addSubview:button];
        sumX = sumX + SCREENX/4;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    _selectV.frame = CGRectMake(0, SCREENY , SCREENX,SCREENX/4);
    [UIView animateWithDuration:0.3f animations:^{
        _selectV.frame = CGRectMake(0, SCREENY - SCREENX/4, SCREENX,SCREENX/4);
    }];

}
#pragma mark backgroundAction

-(void)touchAlpha
{
    [[SelectVC mainSelect] hideView];
}


-(void)chooseSort:(UIButton *)button
{
    NSArray *array = @[@"popularity",@"views",@"comments",@"recent"];
    NSString *sortNameBar = [NSString stringWithFormat:@"%@_bar",array[button.tag]];
    _barButton.image = [UIImage imageNamed:sortNameBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:self userInfo:@{@"sort":array[button.tag]}];
    [[SelectVC mainSelect] hideView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
