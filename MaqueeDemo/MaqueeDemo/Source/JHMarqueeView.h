//
//  JHMarqueeView.h
//  MaqueeDemo
//
//  Created by 陈逸辰 on 2019/4/16.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHMarqueeType) {
    JHMarqueeTypeLeft,
    JHMarqueeTypeRight,
    JHMarqueeTypeReverse,   //水平方向
    JHMarqueeTypeUp
};

@protocol JHMarqueeViewCopyable <NSObject>

- (UIView *)copyMarqueeView;

@end

@interface JHMarqueeView : UIView

@property (nonatomic) JHMarqueeType marqueeType;
@property (nonatomic) CGFloat contentMargin;
@property (nonatomic) int frameInterval;    //设置多少秒一帧
@property (nonatomic) int displaySecond;      //每个内容展示多久，只在JHMarqueeTypeUp有效
@property (nonatomic,strong) NSArray *viewArray;
@property (nonatomic,copy) void (^updateContent)(NSInteger index);
@property (nonatomic,copy) void (^updateAnimate)(NSInteger index);

//重新渲染
- (void)startMarquee;

- (void)stopMarquee;

@end

