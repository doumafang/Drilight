
//define
#import "DEFINE.h"

//view
#import "BucketsCell.h"

@implementation BucketsCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        float smallItemX = (frame.size.width-8)/3;
        
        self.mainIV = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2,frame.size.width-4, (frame.size.width-4)*3/4)];
        self.mainIV.userInteractionEnabled = YES;
        self.mainIV.opaque = YES;
        [self addSubview:self.mainIV];
        
        self.fIV = [[UIImageView alloc]initWithFrame:CGRectMake(2, 4 + self.mainIV.frame.size.height ,smallItemX, smallItemX*3/4)];
        self.fIV.userInteractionEnabled = YES;
        self.fIV.opaque = YES;
        [self addSubview:self.fIV];

        self.sIV = [[UIImageView alloc]initWithFrame:CGRectMake(4 + smallItemX  , 4 + self.mainIV.frame.size.height,smallItemX, smallItemX*3/4)];
        self.sIV.userInteractionEnabled = YES;
        self.sIV.opaque = YES;
        [self addSubview:self.sIV];

        self.tIV = [[UIImageView alloc]initWithFrame:CGRectMake(6 + 2*smallItemX , 4 + self.mainIV.frame.size.height,smallItemX, smallItemX*3/4)];
        self.tIV.userInteractionEnabled = YES;
        self.tIV.opaque = YES;
        [self addSubview:self.tIV];
        
        
        self.buctetsName = [[UILabel alloc]initWithFrame:CGRectMake(10, self.fIV.frame.size.height + self.fIV.frame.origin.y + 5, frame.size.width-10, 15)];
        self.buctetsName.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.buctetsName.textAlignment = NSTextAlignmentLeft;
        self.buctetsName.textColor = RGBA(150, 150, 150, 1);
        [self addSubview:self.buctetsName];
        
        self.bucketsNumber = [[UILabel alloc]initWithFrame:CGRectMake(10, self.buctetsName.frame.origin.y + self.buctetsName.frame.size.height+5, smallItemX, 10)];
        self.bucketsNumber.textColor = TEXTCOLOR;
        self.bucketsNumber.textAlignment = NSTextAlignmentLeft;
        self.bucketsNumber.font = [UIFont fontWithName:@"Nexa Bold" size:11];
        [self addSubview:self.bucketsNumber];

    }
    return self;
}


@end
