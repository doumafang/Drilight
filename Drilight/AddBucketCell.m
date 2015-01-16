
#import "AddBucketCell.h"
#import "DEFINE.h"

@implementation AddBucketCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float itemX = frame.size.width;
        float itemY = frame.size.height;
        float cellY = itemY - 8;

        
        UIView *selectedBV  = [[UIView alloc]init];
        selectedBV.backgroundColor = RGBA(241, 92, 149, 1);
        self.selectedBackgroundView = selectedBV;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0f;
        
        self.imageV = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, cellY * 4/3 , cellY)];
        
        UIView *bgV = [[UIView alloc]initWithFrame:CGRectMake(2, 2,cellY * 4/3+4 , cellY+4)];
        bgV.layer.masksToBounds = YES;
        bgV.layer.cornerRadius = 1.0f;
        bgV.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgV];
        
        
        [self addSubview:self.imageV];

        self.bucketNameL = [[UILabel alloc]initWithFrame:CGRectMake(self.imageV.frame.origin.x + self.imageV.frame.size.width + 10, self.imageV.frame.origin.y + 10, itemX - self.imageV.frame.size.width, 20)];
        self.bucketNameL.font = [UIFont fontWithName:@"Nexa Bold"  size:13];
        self.bucketNameL.textAlignment = NSTextAlignmentLeft;
        self.bucketNameL.textColor = RGBA(85, 85, 85, 1);
        self.bucketNameL.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:self.bucketNameL];
        
        
        self.bucketNumberL = [[UILabel alloc]initWithFrame:CGRectMake(self.bucketNameL.frame.origin.x, self.bucketNameL.frame.origin.y + itemY/2, self.bucketNameL.frame.size.width, 15)];
        self.bucketNumberL.textColor = self.bucketNameL.textColor;
        self.bucketNumberL.textAlignment = NSTextAlignmentLeft;
        self.bucketNumberL.font = [UIFont fontWithName:@"Nexa Bold"  size:9];
        self.bucketNumberL.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:self.bucketNumberL];
        
        
        
        
    }
    return self;
}

@end
