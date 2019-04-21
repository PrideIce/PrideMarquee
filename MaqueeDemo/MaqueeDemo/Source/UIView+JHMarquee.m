//
//  UIView+JHMarquee.m
//  MaqueeDemo
//
//  Created by 陈逸辰 on 2019/4/16.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "UIView+JHMarquee.h"

@implementation UIView (JHMarquee)

- (UIView *)copyMarqueeView
{
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:NO error:nil];
    UIView *copyView = [NSKeyedUnarchiver unarchivedObjectOfClass:UIView.class fromData:archivedData error:nil];
    return copyView;
}

@end
