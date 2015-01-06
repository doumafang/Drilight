

#import "SigninVC.h"

#import "ShotsVC.h"
#import "DetailVC.h"

#import "DEFINE.h"

#import "AFNetworking.h"

@interface SigninVC ()<UIWebViewDelegate>
{
    UIView *_signinV;
}
@end

@implementation SigninVC

@synthesize animating = _animating;

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (SigninVC *)sharedSignin
{
    @synchronized(self)
    {
        static SigninVC *sharedSignin = nil;
        if (sharedSignin == nil)
        {
            sharedSignin = [[self alloc] init];
        }
        return sharedSignin;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    float viewX = self.view.frame.size.width;
    float viewY = self.view.frame.size.height;
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.userInteractionEnabled = YES;
    [bg setImage:[UIImage imageNamed:@"Default-568h"]];
    self.view = bg;

    
    UIImageView *drilight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"drilight"]];
    drilight.frame = CGRectMake(viewX/10*3, 0.28*viewY, viewX/5*2 , viewX/5*2/13*5);
    [self.view addSubview:drilight];

    UIImageView *uniquestudio = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"UniqueStudio"]];
    uniquestudio.frame = CGRectMake(0.39*viewX, viewY-0.22*viewX/14*3-10, 0.22*viewX, 0.22*viewX/14*3);
    [self.view addSubview:uniquestudio];

    
    UIButton *signinB = [[UIButton alloc]initWithFrame:CGRectMake(viewX/8, 0.73*viewY, viewX/4*3, viewX/8)];
    signinB.backgroundColor = RGBA(254, 142, 185, 0.5);
    [signinB setTitle:@"Sign In" forState:UIControlStateNormal];
    [signinB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signinB.titleLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:12]];
    [signinB addTarget:self action:@selector(signAction:) forControlEvents:UIControlEventTouchUpInside];
    signinB.tag = 0;
    [self.view addSubview:signinB];

    
    
    UIButton *signupB = [[UIButton alloc]initWithFrame:CGRectMake(viewX/8, 0.73*viewY+viewX/6*1, viewX/4*3, viewX/8)];
    signupB.backgroundColor = RGBA(150, 160, 249, 0.5);
    [signupB setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupB.titleLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:12]];
    [signupB addTarget:self action:@selector(signAction:) forControlEvents:UIControlEventTouchUpInside];
    signupB.tag = 1;
    [self.view addSubview:signupB];

}

-(void)signAction:(UIButton *)button
{
  
    UIView *signinV = [[UIView alloc]initWithFrame:[self offscreenFrame]];
    signinV.backgroundColor = RGBA(50, 50, 50, 1);
    UINavigationBar *nav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, UI_NAVIGATION_BAR_HEIGHT+UI_STATUS_BAR_HEIGHT)];
    nav.backgroundColor = RGBA(50, 50, 50, 1);
    nav.barStyle = UIBarStyleBlackTranslucent;
    [signinV addSubview:nav];
    _signinV = signinV;
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [nav setTitleTextAttributes:attributes];
    [nav setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *leftB = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"xia"] style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    UINavigationItem *item = [[UINavigationItem alloc]init];
    item.leftBarButtonItem = leftB;
   
    [nav pushNavigationItem:item animated:NO];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width , 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Honduro" size:20]];
    [nav addSubview:titleLabel];
    
    UIWebView *loginW = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width , self.view.frame.size.height - 64)];
    loginW.delegate = self;
    loginW.backgroundColor = RGBA(66, 66, 66, 1);
    
    switch (button.tag) {
        case 0:
        {
            titleLabel.text = @"Sign In";
            NSString *str = [NSString stringWithFormat:@"%@?client_id=%@&scope=public+write+comment+upload",AUTHORIZE_URL,CLIENT_ID];
            NSString *urlStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *loginRequest = [NSURLRequest requestWithURL:url];
            [loginW loadRequest:loginRequest];
            [signinV addSubview:loginW];
            break;
        }
        case 1:
        {
            titleLabel.text = @"Sign Up";
            NSString *str = [NSString stringWithFormat:@"%@",SIGNUP_URL];
            NSString *urlStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *loginRequest = [NSURLRequest requestWithURL:url];
            [loginW loadRequest:loginRequest];
            [signinV addSubview:loginW];
            break;
        }
    }
    
    [self.view addSubview:signinV];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationDelegate:self];
    signinV.frame = [self onscreenFrame];
    [UIView commitAnimations];

}

-(void)leftAction
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(remove)];
    _signinV.frame = [self offscreenFrame];
    [UIView commitAnimations];

}
-(void)remove
{
    [_signinV removeFromSuperview];
    
}

#pragma -mark WebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *string = [request.URL absoluteString];
    
    NSRange range = [string rangeOfString:@"code="];

    if (range.length > 0) {
        NSString *postURlStr = TOKEN_URL;
        NSString *code = [string substringFromIndex:range.location+5];
        NSDictionary *kv = @{@"client_id":CLIENT_ID,@"client_secret":CLIENT_SECRET,@"code":code};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:postURlStr parameters:kv success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dic = (NSDictionary * )responseObject;
            
            [[NSUserDefaults standardUserDefaults]setObject:[dic objectForKey:@"access_token"] forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self hideGuide];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {                    }];
        
    }
    return YES;
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


+ (void)show
{
    [[SigninVC sharedSignin] showGuide];
}


- (void)showGuide
{
    if (!_animating && self.view.superview == nil)
    {
        [SigninVC sharedSignin].view.frame = [self offscreenFrame];
        
        [[self mainWindow] addSubview:[SigninVC sharedSignin].view];
        
        _animating = YES;

        [SigninVC sharedSignin].view.frame = [self onscreenFrame];
    }
}

- (void)guideShown
{
    _animating = NO;
}

+ (void)hide
{

    [[SigninVC sharedSignin] hideGuide];
}

- (void)hideGuide
{
    _animating = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(guideHidden)];
    [SigninVC sharedSignin].view.frame = [self offscreenFrame];
    [UIView commitAnimations];
}

- (void)guideHidden
{
    _animating = NO;
    [[[SigninVC sharedSignin] view] removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
