
#import "FollowCell.h"
#import "DEFINE.h"


@implementation FollowCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0f;
        
        
        
        _avatarV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENX/32, SCREENX/64, SCREENX/8, SCREENX/8)];
        self.avatarV.opaque = YES;
        self.avatarV.userInteractionEnabled = YES;
        self.avatarV.layer.masksToBounds = YES;
        self.avatarV.layer.cornerRadius = _avatarV.frame.size.height/2;
         self.avatarV.opaque = YES;
        self.avatarV.backgroundColor = [UIColor whiteColor];
        [self addSubview:_avatarV];
        
        
        _followB = [[UIButton alloc]initWithFrame:CGRectMake(SCREENX*21/32, SCREENX/32, SCREENX*9/32,SCREENX/12)];
        self.followB.layer.masksToBounds = YES;
        self.followB.layer.cornerRadius = _followB.frame.size.height/2;
        self.followB.layer.borderColor = [UIColor colorWithRed:224/255.0f green:24/255.0f blue:87/255.0f alpha:1.0].CGColor;
        self.followB.layer.borderWidth = 1.0f;
        self.followB.opaque = YES;
        
        [self.followB setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.followB setTitle:@"FOLLOWED" forState:UIControlStateSelected];
        
        [self.followB setTitleColor:[UIColor colorWithRed:224/255.0f green:24/255.0f blue:87/255.0f alpha:1.0] forState:UIControlStateNormal];
        [self.followB setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [self.followB.titleLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:11]];
        [self addSubview:_followB];

        
        
        
       
        
        
        _userL = [[UILabel alloc]initWithFrame:CGRectMake(_avatarV.frame.size.width+_avatarV.frame.origin.x*2, _avatarV.frame.origin.y,  _followB.frame.origin.x - _avatarV.frame.size.width - _avatarV.frame.origin.x - 10, 20)];
        self.userL.opaque = YES;
        self.userL.textColor = [UIColor blackColor];
        self.userL.textAlignment = NSTextAlignmentLeft;
        self.userL.userInteractionEnabled = YES;
        self.userL.opaque = YES;
        self.userL.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        [self addSubview:_userL];
        
        
        
        _descriptionL = [[UILabel alloc]initWithFrame:CGRectMake(_userL.frame.origin.x, frame.size.height / 2,_userL.frame.size.width, 15)];
        self.descriptionL.font = [UIFont systemFontOfSize:10];
        self.descriptionL.textAlignment = NSTextAlignmentLeft;
        self.descriptionL.textColor = RGBA(85, 85, 85, 1);
        self.descriptionL.opaque = YES;
        [self addSubview:_descriptionL];

        
        
        
        
        
        
        
    }
    return self;
}

@end
