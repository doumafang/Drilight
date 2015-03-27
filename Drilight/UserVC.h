

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

#import "DetailVC.h"
#import "USER.h"


@interface UserVC : UIViewController

//Pass

@property NSString *userID;
@property NSManagedObjectID *userObjectID;

@property USER *user;
@property AppDelegate * myDelegate;

@end
