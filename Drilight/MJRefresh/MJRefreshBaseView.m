

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"
#import <objc/message.h>

@interface  MJRefreshBaseView()<UIScrollViewDelegate>
{
    __weak UIImageView *_arrowImage;
}
@end

@implementation MJRefreshBaseView
#pragma mark - 控件初始化

- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"refreshDrilight"]];
        arrowImage.bounds = CGRectMake(0, 0, 30, 30);
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = MJRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        // 2.设置默认状态
        self.state = MJRefreshStateNormal;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = self.mj_width * 0.5 ;
    self.arrowImage.center = CGPointMake(arrowX, self.mj_height * 0.6);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置宽度
        self.mj_width = newSuperview.mj_width;
        // 设置位置
        self.mj_x = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == MJRefreshStateWillRefreshing) {
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return MJRefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.state == MJRefreshStateRefreshing) {
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = MJRefreshStateRefreshing;
        } else {

            _state = MJRefreshStateWillRefreshing;
            
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = MJRefreshStateNormal;
    });
}


- (void)setState:(MJRefreshState)state
{
    // 0.存储当前的contentInset
    if (self.state != MJRefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回(暂时不返回)
    if (self.state == state) return;
    
    // 2.旧状态
    MJRefreshState oldState = self.state;
    
    // 3.存储状态
    _state = state;
    
    // 4.根据状态执行不同的操作
    switch (state) {
		case MJRefreshStateNormal: // 普通状态
        {
            if (oldState == MJRefreshStateRefreshing) {


                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 等头部回去

                    // 停止转圈圈
                    [self drilightEndAnimation];

                });
                // 直接返回
                return;
            } else {
                
                [self drilightEndAnimation];


            }
			break;
        }
            
        case MJRefreshStatePulling:
            break;
            
		case MJRefreshStateRefreshing:
        {
            // 开始转圈圈
            [self drilightBeginAnimation];
            // 隐藏箭头
            
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
			break;
        }
        default:
            break;
	}
    
}

-(void)drilightBeginAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = 0.8f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    [self.arrowImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    
}


-(void)drilightEndAnimation
{
    [self.arrowImage.layer removeAnimationForKey:@"rotationAnimation"];
}

@end