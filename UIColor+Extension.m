//
//  UIColor+Extension.m
//  DrawBoard
//
//  Created by 杨英俊 on 18-1-10.
//  Copyright © 2018年 杨英俊. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

static NSArray *_colors;

+ (NSArray *)getColorArray {
    if (_colors == nil) {
        _colors = @[
       [UIColor blackColor], // 黑色
       [UIColor darkGrayColor], // 深灰色
       [UIColor lightGrayColor], // 浅灰色
       [UIColor whiteColor], // 白色
       [UIColor grayColor], // 灰色
       [UIColor redColor], // 红色
       [UIColor greenColor], // 绿色
       [UIColor blueColor], // 蓝色
       [UIColor cyanColor], // 青色(红色与绿色之间)
       [UIColor yellowColor], // 黄色
       [UIColor magentaColor], // 洋红色(红色与蓝色之间)
       [UIColor orangeColor], // 橙色
       [UIColor purpleColor], // 紫色
       [UIColor brownColor] // 棕色,
                    ];
    }
    return _colors;
}
@end
