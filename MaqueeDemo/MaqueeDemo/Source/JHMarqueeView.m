//
//  JHMarqueeView.m
//  MaqueeDemo
//
//  Created by 陈逸辰 on 2019/4/16.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "JHMarqueeView.h"
#import "UIView+JHMarquee.h"

@interface JHMarqueeView ()

@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) CADisplayLink *marqueeDisplayLink;
@property (nonatomic) CGFloat pointsPerFrame;
@property (nonatomic) BOOL isReversing;
@property (nonatomic) int displayedCount;
@property (nonatomic) CGFloat firstItemWidth;
@property (nonatomic) BOOL noNeedMove;

@end

@implementation JHMarqueeView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 骚操作：当视图将被移除父视图的时候，newSuperview就为nil。在这个时候，停止掉CADisplayLink，断开循环引用，视图就可以被正确释放掉了。
    if (newSuperview == nil) {
        [self stopMarquee];
    }
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews
{
    self.marqueeType = JHMarqueeTypeLeft;
    self.contentMargin = 0;
    self.frameInterval = 1;
    self.displaySecond = 3;
    self.displayedCount = 0;
    self.pointsPerFrame = 1;
    
    self.backgroundColor = UIColor.clearColor;
    self.clipsToBounds = YES;
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.containerView];
}

- (void)setViewArray:(NSArray *)viewArray
{
    if (viewArray.count > 0) {
        NSMutableArray *mutableArray = viewArray.mutableCopy;
        UIView *firstView = viewArray[0];
        UIView *copyView = firstView.copyMarqueeView;
        [mutableArray addObject:copyView];
        _viewArray = mutableArray.copy;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.viewArray.count) {
        return;
    }
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    if (self.marqueeType == JHMarqueeTypeUp) {
        CGFloat Y = 0, H = self.bounds.size.height;
        for (UIView *view in self.viewArray) {
            CGRect frame = view.bounds;
            frame.origin.y = Y;
            view.frame = frame;
            [self.containerView addSubview:view];
            [view sizeToFit];
            Y += H + _contentMargin;
        }
        _containerView.frame = CGRectMake(0, 0, self.bounds.size.width, Y);
    }
    else if (self.marqueeType == JHMarqueeTypeLeft) {
        CGFloat X = 0;
        int i = 0;
        for (UIView *view in self.viewArray) {
            CGRect frame = view.bounds;
            frame.origin.x = X;
            frame.origin.y = 5;
            view.frame = frame;
            [self.containerView addSubview:view];
            [view sizeToFit];
            if (i == 0) {
                self.firstItemWidth = view.frame.size.width;
                i++;
            }
            else if (_viewArray.count == 2 && i == 1 && view.frame.size.width <= self.frame.size.width) {
                //不需要滚动，隐藏复制视图
                view.hidden = YES;
                self.noNeedMove = YES;
            }
            X += view.frame.size.width + _contentMargin;
        }
        _containerView.frame = CGRectMake(0, 0, X, self.bounds.size.height);
    }
}

- (void)startMarquee
{
    [self stopMarquee];
    
    _marqueeDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(processMarquee)];
    _marqueeDisplayLink.preferredFramesPerSecond = self.frameInterval;
    [_marqueeDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMarquee
{
    [_marqueeDisplayLink invalidate];
    _marqueeDisplayLink = nil;
    
    CGRect frame = _containerView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    _containerView.frame = frame;
}

- (void)processMarquee
{
    CGRect frame = _containerView.frame;
    switch (self.marqueeType) {
        case JHMarqueeTypeUp:
        {
            if (_viewArray.count == 2) {
                //不需要滚动
                return;
            }
            
            _displayedCount++;
            if (_displayedCount < _displaySecond * 60) {
                return;
            }
            
            CGFloat cellHeight = self.bounds.size.height + _contentMargin;
            CGFloat targetY = - (frame.size.height - cellHeight);
            frame.origin.y -= _pointsPerFrame;
            if (frame.origin.y <= targetY) {
                frame.origin.y = 0;
            }
            _containerView.frame = frame;
            
            int bigH = frame.origin.y;
            int smallH = cellHeight;
            if (bigH % smallH == 0) {
                _displayedCount = 0;
                if (self.updateContent) {
                    self.updateContent(-bigH/smallH);
                }
            }
            int HH = bigH - cellHeight + 10;
            if (HH % smallH == 0) {
                if (self.updateAnimate) {
                    self.updateAnimate(-HH/smallH);
                }
            }
        }
            break;
            
        case JHMarqueeTypeLeft:
        {
            if (self.noNeedMove) {
                //不需要滚动
                return;
            }
            CGFloat targetX = - (frame.size.width - self.firstItemWidth - _contentMargin - 15);
            frame.origin.x -= _pointsPerFrame;
            if (frame.origin.x <= targetX) {
                frame.origin.x = 0;
            }
            _containerView.frame = frame;
        }
            break;
            
        default:
            break;
    }
}

@end

