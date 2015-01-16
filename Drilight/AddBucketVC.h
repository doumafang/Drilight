

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "USER.h"
#import "SHOTS.h"

@interface AddBucketVC : UIViewController


+ (AddBucketVC *)mainAdd;

+(void)addBucketShow:(SHOTS *)shots inButton:(UIButton *)button;


@end
