

#import <UIKit/UIKit.h>
#import "HTMLLabel.h"
@interface CommentsCell : UITableViewCell

@property UIImageView *avatarIV;
@property UILabel *userL;
@property UILabel *timeL;
@property UILabel *likesL;
@property HTMLLabel *commentL;

@property UIButton *likeB;

@property UIView *lineV;
@end
