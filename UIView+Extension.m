//
//  UIView+Extension.m
//  DrawBoard
//
//  Created by 杨英俊 on 18-1-10.
//  Copyright © 2018年 杨英俊. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

#pragma mark ~~~~~~~~~~ Setter ~~~~~~~~~~
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setW:(CGFloat)w {
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (void)setH:(CGFloat)h {
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

- (void)setCenterx:(CGFloat)centerx {
    CGPoint center = self.center;
    center.x = centerx;
    self.center = center;
}

- (void)setCentery:(CGFloat)centery {
    CGPoint center = self.center;
    center.y = centery;
    self.center = center;
}

#pragma mark ~~~~~~~~~~ Getter ~~~~~~~~~~
- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)w {
    return self.frame.size.width;
}

- (CGFloat)h {
    return self.frame.size.height;
}

- (CGFloat)centerx {
    return self.center.x;
}

- (CGFloat)centery {
    return self.center.y;
}

@end
