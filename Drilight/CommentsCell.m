
#import "DEFINE.h"
#import "CommentsCell.h"

@implementation CommentsCell

- (void)awakeFromNib {
    // Initialization code
}



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        float width = UI_SCREEN_WIDTH;
        
        self.backgroundColor = BG_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.opaque = YES;

        self.avatarIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 50, 50)];
        self.avatarIV.layer.masksToBounds = YES;
        self.avatarIV.layer.cornerRadius = 25;
        self.avatarIV.userInteractionEnabled = YES;
        self.avatarIV.opaque = YES;
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
        [self.avatarIV addGestureRecognizer:avatarTap];
        [self addSubview:self.avatarIV];

        
        self.likeB = [[UIButton alloc]initWithFrame:CGRectMake(width - 50,self.avatarIV.frame.origin.y, 20, 20)];
        self.likeB.opaque = YES;
        [self.likeB setBackgroundImage:[UIImage imageNamed:@"commentLike_0"] forState:UIControlStateNormal];
        [self.likeB setBackgroundImage:[UIImage imageNamed:@"commentLike_1"] forState:UIControlStateSelected];
        [self addSubview:self.likeB];
        
        
        self.likesL = [[UILabel alloc]initWithFrame:CGRectMake(self.likeB.frame.origin.x + self.likeB.frame.size.width, self.likeB.frame.origin.y, 30, 20)];
        self.likesL.font = [UIFont systemFontOfSize:10];
        self.likesL.textAlignment = NSTextAlignmentLeft;
        self.likesL.textColor = RGBA(146, 146, 146, 1);
        self.likesL.opaque = YES;
        [self addSubview:self.likesL];
        
        
        self.userL = [[UILabel alloc]initWithFrame:CGRectMake((self.avatarIV.frame.origin.x)*1.5+self.avatarIV.frame.size.width,self.avatarIV.frame.origin.y , 200, 20)];
        self.userL.textColor = RGBA(224, 24, 87, 1);
        self.userL.textAlignment = NSTextAlignmentLeft;
        self.userL.userInteractionEnabled = YES;
        self.userL.opaque = YES;
        self.userL.font = [UIFont fontWithName:@"Nexa Bold" size:13];
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
        [self.userL addGestureRecognizer:userTap];
        [self addSubview:self.userL];
        
        
        self.commentL = [[HTMLLabel alloc]init];
        self.commentL.textColor = RGBA(85, 85, 85, 1);
        self.commentL.font = [UIFont systemFontOfSize:11];
        self.commentL.textAlignment = NSTextAlignmentLeft;
        self.commentL.numberOfLines = 0;
        self.commentL.opaque = YES;
        [self addSubview:self.commentL];
        
        
        self.timeL = [[ UILabel alloc]initWithFrame:CGRectZero];
        self.timeL.textColor = RGBA(146, 146, 146, 1);
        self.timeL.textAlignment = NSTextAlignmentRight;
        self.timeL.font = [UIFont systemFontOfSize:8];
        self.timeL.opaque = YES;
        [self addSubview:self.timeL];
        
        
        self.lineV = [[UIView alloc]init];
        self.lineV.backgroundColor = RGBA(200, 200, 200, 1);
        self.lineV.opaque = YES;
        [self addSubview:self.lineV];

        
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
