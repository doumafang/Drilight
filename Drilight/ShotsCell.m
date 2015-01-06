#define TEXTCOLOR [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]
#define TEXTFONT [UIFont fontWithName:@"Helvetica Light" size:8]

#import "ShotsCell.h"
#import "AppDelegate.h"

#import "SHOTS.h"
#import "IMAGES.h"
@interface ShotsCell ()
@property AppDelegate *myDelegate;
@end

@implementation ShotsCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 1.5f;
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        


        self.shotsIV = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, frame.size.width - 4, (frame.size.height - 4)*3/4)];
        self.shotsIV.layer.masksToBounds = YES;
        self.shotsIV.layer.cornerRadius = 1.0f;
        self.shotsIV.opaque = YES;
        [self addSubview:self.shotsIV];
        
        self.avatarIV = [[UIImageView alloc]initWithFrame:CGRectMake(8, self.shotsIV.frame.size.height+10, frame.size.height - 18 - (frame.size.height - 4)*3/4, frame.size.height - 18 - (frame.size.height - 4)*3/4)];
        self.avatarIV.layer.masksToBounds = YES;
        self.avatarIV.layer.cornerRadius = (frame.size.height - 18 - (frame.size.height - 4)*3/4)/2;
        self.avatarIV.opaque = YES;
        [self addSubview:self.avatarIV];
        
        


        
        float itemXY =  frame.size.width * 2/25;

        
        UIImageView *viewsIV= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shots_views"]];
        viewsIV.frame = CGRectMake(20 +self.avatarIV.frame.size.width, self.avatarIV.frame.origin.y+self.avatarIV.frame.size.height/2-itemXY/2, itemXY, itemXY);
        viewsIV.opaque = YES;
        [self addSubview:viewsIV];

        self.views_countL = [[ UILabel alloc]initWithFrame:CGRectMake(viewsIV.frame.origin.x +viewsIV.frame.size.width+5, viewsIV.frame.origin.y, 25, itemXY)];
        self.views_countL.textColor = TEXTCOLOR;
        self.views_countL.font = TEXTFONT;
        self.views_countL.textAlignment = NSTextAlignmentLeft;
        self.views_countL.opaque = YES;
        [self addSubview:self.views_countL];
        

        
        
        UIImageView *commentsIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shots_comments"]];
        commentsIV.frame = CGRectMake(25+self.avatarIV.frame.size.width+frame.size.width/40*9, self.avatarIV.frame.origin.y+self.avatarIV.frame.size.height/2-itemXY/2, itemXY, itemXY);
        commentsIV.opaque = YES;
        [self addSubview:commentsIV];
        
        self.comments_countL = [[ UILabel alloc]initWithFrame:CGRectMake(commentsIV.frame.origin.x +commentsIV.frame.size.width+5, commentsIV.frame.origin.y, 25, itemXY)];
        self.comments_countL.textColor = TEXTCOLOR;
        self.comments_countL.font = TEXTFONT;
        self.comments_countL.textAlignment = NSTextAlignmentLeft;
        self.comments_countL.opaque = YES;
        [self addSubview:self.comments_countL];

        
        UIImageView *likesIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shots_likes"]];
        likesIV.frame = CGRectMake(30+self.avatarIV.frame.size.width+frame.size.width/20*9, self.avatarIV.frame.origin.y+self.avatarIV.frame.size.height/2-itemXY/2, itemXY, itemXY);
        likesIV.opaque = YES;
        [self addSubview:likesIV];
        
        self.likes_countL = [[ UILabel alloc]initWithFrame:CGRectMake(likesIV.frame.origin.x +likesIV.frame.size.width+5, likesIV.frame.origin.y, 25, itemXY)];        self.likes_countL.textColor = TEXTCOLOR;
        self.likes_countL.font = TEXTFONT;
        self.likes_countL.textAlignment = NSTextAlignmentLeft;
        self.likes_countL.opaque = YES;
        [self addSubview:self.likes_countL];

        
        self.gifIV = [[UIImageView alloc]init];
        self.gifIV.frame = CGRectMake(frame.size.width - 35, 5, 25, 25);
        self.gifIV.opaque = YES;
        [self addSubview:self.gifIV];
        
        
        
        
    }
    return self;
}


@end
