

#ifndef Drilight_DEFINE_h
#define Drilight_DEFINE_h

//颜色
#define BG_COLOR [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0];
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/1.0];

//屏幕固定高度
#define UI_NAVIGATION_BAR_HEIGHT        44
#define UI_STATUS_BAR_HEIGHT            20

#define UI_SCREEN_WIDTH                 [[UIScreen mainScreen] bounds].size.width
#define UI_SCREEN_HEIGHT                [[UIScreen mainScreen] bounds].size.height
#define UI_SCREEN_BOUNDS                [[UIScreen mainScreen] bounds]


//DRIBBBLE_API
#define POPULAR_API  @"https://api.dribbble.com/v1/shots?page=1&per_page=10&access_token="

#define CLIENT_ID @"57762c2c3eb608a90fbb385b963e4cf1e34f08dce88c1d24cdbbf9f6fad1d3e8"
#define CLIENT_SECRET @"46621dde79531416c6ffa128c150b15eff45cf71e11404e41c36b55e829777b2"

#define AUTHORIZE_URL @"https://dribbble.com/oauth/authorize"
#define TOKEN_URL @"https://dribbble.com/oauth/token"

#define SIGNUP_URL @"https://dribbble.com/signup"

//G－C－D
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)


//封装
#define EntityObjects(name) [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.myDelegate.managedObjectContext];



#endif
