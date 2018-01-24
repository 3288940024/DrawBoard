//
//  ViewController.m
//  DrawBoard
//
//  Created by 杨英俊 on 18-1-10.
//  Copyright © 2018年 杨英俊. All rights reserved.
//

#import "ViewController.h"
#import "DrawBoardView.h"

@interface ViewController () 
/** 画板 */
@property (nonatomic,strong) DrawBoardView *draw;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 画板
    self.draw = [[DrawBoardView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.draw];
}



@end
