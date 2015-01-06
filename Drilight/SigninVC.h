
#import <UIKit/UIKit.h>



@interface SigninVC : UIViewController
{
    BOOL _animating;

}



@property (nonatomic, assign) BOOL animating;



+(SigninVC *)sharedSignin;

+(void)show;
+(void)hide;



@end
