
#import <UIKit/UIKit.h>



@interface SignVC : UIViewController
{
    BOOL _animating;

}



@property (nonatomic, assign) BOOL animating;



+(SignVC *)sharedSignin;

+(void)show;
+(void)hide;



@end
