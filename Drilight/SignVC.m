

#import "SignVC.h"

#import "ShotsVC.h"
#import "DetailVC.h"

#import "DEFINE.h"
#import "USER.h"

#import "AFNetworking.h"
#import "AppDelegate.h"

@interface SignVC ()<UIWebViewDelegate>
{
    UIView *_signinV;

}
@property UIImageView *drilight;
@property AppDelegate *myDelegate;

@end

@implementation SignVC

@synthesize animating = _animating;

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (SignVC *)sharedSignin
{
    @synchronized(self)
    {
        static SignVC *sharedSignin = nil;
        if (sharedSignin == nil)
        {
            sharedSignin = [[self alloc] init];
        }
        return sharedSignin;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 0.8 ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    [self.drilight.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

}
- (void)viewDidLoad {
    
    [super viewDidLoad];

    float viewX = self.view.frame.size.width;
    float viewY = self.view.frame.size.height;
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.userInteractionEnabled = YES;
    [bg setImage:[UIImage imageNamed:@"SignBG"]];
    self.view = bg;
    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    
    self.drilight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default"]];
    self.drilight.frame = CGRectMake(viewX/14*5, 0.28*viewY, viewX/7*2 , viewX/7*2);
    [self.view addSubview:self.drilight];

    UIImageView *uniquestudio = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"UniqueStudio"]];
    uniquestudio.frame = CGRectMake(0.39*viewX, viewY-0.22*viewX/14*3-10, 0.22*viewX, 0.22*viewX/14*3);
    [self.view addSubview:uniquestudio];

    
    UIButton *signinB = [[UIButton alloc]initWithFrame:CGRectMake(viewX/8, 0.73*viewY, viewX/4*3, viewX/8)];
    [signinB setTitle:@"Sign In" forState:UIControlStateNormal];
    [signinB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signinB setBackgroundImage:[UIImage imageNamed:@"signIn_1"] forState:UIControlStateNormal];
    [signinB setBackgroundImage:[UIImage imageNamed:@"signIn_2"] forState:UIControlStateHighlighted];
    
    
    
    [signinB.titleLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:12]];
    [signinB addTarget:self action:@selector(signAction:) forControlEvents:UIControlEventTouchUpInside];
    signinB.tag = 0;
    [self.view addSubview:signinB];

    
    
    UIButton *signupB = [[UIButton alloc]initWithFrame:CGRectMake(viewX/8, 0.73*viewY+viewX/6*1, viewX/4*3, viewX/8)];
    signupB.backgroundColor = RGBA(150, 160, 249, 0.5);
    [signupB setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupB setBackgroundImage:[UIImage imageNamed:@"signUp_1"] forState:UIControlStateNormal];
    [signupB setBackgroundImage:[UIImage imageNamed:@"signUp_2"] forState:UIControlStateHighlighted];

    [signupB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupB.titleLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:12]];
    [signupB addTarget:self action:@selector(signAction:) forControlEvents:UIControlEventTouchUpInside];
    signupB.tag = 1;
    [self.view addSubview:signupB];
    
    
    //旋转动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 0.8 ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    [self.drilight.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    
    
    // 透明动画
    [self drilightAnimationBegin];
    
}


-(void)drilightAnimationBegin
{
    float viewX = self.view.frame.size.width;
    float viewY = self.view.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:7.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDidStopSelector:@selector(drilightAnimationBack)];
    
    self.drilight.alpha = 0.3f;
    self.drilight.frame = CGRectMake(viewX/7*2, 0.28*viewY-viewX/14, viewX/7*3 , viewX/7*3);
    
    [UIView commitAnimations];

    
}

-(void)drilightAnimationBack
{
    float viewX = self.view.frame.size.width;
    float viewY = self.view.frame.size.height;
    

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDidStopSelector:@selector(drilightAnimationBegin)];
    
    self.drilight.alpha = 1.0f;
    self.drilight.frame = CGRectMake(viewX/14*5, 0.28*viewY, viewX/7*2 , viewX/7*2);

    [UIView commitAnimations];

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
    UIBarButtonItem *leftB = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
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

        NSString *code = [string substringFromIndex:range.location + 5];
        
        NSDictionary *kv = @{@"client_id":CLIENT_ID,@"client_secret":CLIENT_SECRET,@"code":code};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:postURlStr parameters:kv success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dic = (NSDictionary * )responseObject;
            
            NSString *access_token = [dic objectForKey:@"access_token"];
            
            [[NSUserDefaults standardUserDefaults]setObject:access_token forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self userNerAction:access_token];
            
            [self hideGuide];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    return YES;
}

-(void)userNerAction:(NSString *)access_token
{
    BACK((^{
        NSString *str = [[NSString stringWithFormat:@"https://api.dribbble.com/v1/user?access_token=%@",access_token]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
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
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error:%@ ___ %@",error ,[error userInfo]);
        }];
        [operation start];
        
    }));
    
}

-(void)douma_save
{
    NSError *error = nil;
    if (![self.myDelegate.managedObjectContext save:&error])
    {
        NSLog(@"Error%@:%@",error,[error userInfo]);
    }
    
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
    [[SignVC sharedSignin] showGuide];
}


- (void)showGuide
{
    if (!_animating && self.view.superview == nil)
    {
        [SignVC sharedSignin].view.frame = [self offscreenFrame];
        
        [[self mainWindow] addSubview:[SignVC sharedSignin].view];
        
        _animating = YES;

        [SignVC sharedSignin].view.frame = [self onscreenFrame];
    }
}

- (void)guideShown
{
    _animating = NO;
}

+ (void)hide
{

    [[SignVC sharedSignin] hideGuide];
}

- (void)hideGuide
{
    _animating = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(guideHidden)];
    [SignVC sharedSignin].view.frame = [self offscreenFrame];
    [UIView commitAnimations];
}

- (void)guideHidden
{
    _animating = NO;
    [[[SignVC sharedSignin] view] removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
