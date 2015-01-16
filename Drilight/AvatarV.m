
#import "AvatarV.h"

@implementation AvatarV
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = BG_COLOR;
        
        self.avatarIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
        self.avatarIV.layer.masksToBounds = YES;
        self.avatarIV.opaque = YES;
        self.avatarIV.layer.cornerRadius = 25;
        self.avatarIV.userInteractionEnabled = YES;
        self.avatarIV.backgroundColor = [UIColor blackColor];
        [self addSubview:self.avatarIV];
        
        
    
        
        self.userL = [[UILabel alloc]initWithFrame:CGRectMake((self.avatarIV.frame.origin.x)*1.5+self.avatarIV.frame.size.width,self.avatarIV.frame.origin.y ,self.frame.size.width - 50 - (self.avatarIV.frame.origin.x)*1.5-self.avatarIV.frame.size.width, 20)];
        self.userL.textColor = RGBA(224, 24, 87, 1);
        self.userL.textAlignment = NSTextAlignmentLeft;
        self.userL.userInteractionEnabled = YES;
        self.userL.font = [UIFont fontWithName:@"Nexa Bold" size:13];
        self.userL.opaque = YES;
        [self addSubview:self.userL];
        
        
        
        
        self.descriptionL = [[HTMLLabel alloc]init];
        self.descriptionL.textColor = RGBA(85, 85, 85, 1);
        self.descriptionL.font = [UIFont systemFontOfSize:11];
        self.descriptionL.textAlignment = NSTextAlignmentLeft;
        self.descriptionL.numberOfLines = 0;
        self.descriptionL.opaque = YES;
        [self addSubview:self.descriptionL];
        
        
        
        self.timeL = [[ UILabel alloc]initWithFrame:CGRectZero];
        self.timeL.textColor = RGBA(146, 146, 146, 1);
        self.timeL.textAlignment = NSTextAlignmentRight;
        self.timeL.font = [UIFont systemFontOfSize:8];
        self.timeL.opaque = YES;
        [self addSubview:self.timeL];
        
        
        self.commentsCountL = [[UILabel alloc]initWithFrame:CGRectZero];
        self.commentsCountL.textColor = RGBA(85, 85, 85, 1);
        self.commentsCountL.textAlignment = NSTextAlignmentLeft;
        self.commentsCountL.font = [UIFont systemFontOfSize:10];
        self.commentsCountL.userInteractionEnabled = YES;
        self.commentsCountL.opaque = YES;
        [self addSubview:self.commentsCountL];
        
        
        self.lineV = [[UIView alloc]init];
        self.lineV.backgroundColor = RGBA(200, 200, 200, 1);
        self.lineV.opaque = YES;
        [self addSubview:self.lineV];


        
    }
    return self;

}

@end
