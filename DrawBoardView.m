//
//  DrawBoardView.m
//  DrawBoard
//
//  Created by 杨英俊 on 18-1-10.
//  Copyright © 2018年 杨英俊. All rights reserved.
//

typedef enum {
    noState, // 没有选择图形
    lineState, // 直线
    squareState, // 方形
    roundState // 圆形
}GraphicsState;

#define Width self.frame.size.width
#define Height self.frame.size.height
#define HeadToolHeight 64
#define FootToolHeight Height/5
#define buttonH 40


#import "DrawBoardView.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"

@interface DrawBoardView () <UIScrollViewDelegate>
@end

@implementation DrawBoardView  {
    UIView *_headTool; // 头部工具栏
    UITapGestureRecognizer *_tap; // 点击手势
    UIPanGestureRecognizer *_pan; // 拖动手势
    UILongPressGestureRecognizer *_longPress; // 长按手势
    UIButton *_undo; // 撤销
    UIButton *_back; // 返回
    GraphicsState _state; // 样式状态
    NSInteger _index; // 记录线条状态索引
    UIButton *_selectState; // 选中的样式
    UIView *_footTool; // 底部工具栏
    UIView *_lineWidthView; // 线条宽度视图
    UIView *_lineColorView; // 线条颜色视图
    UIScrollView *_lineColorScrollView; // 线条颜色滚动视图
    UIPageControl *_pageControl; // 滚动视图指示器
    UIView *_selectView; // 宽度/颜色选择视图
    UIButton *_selectViewBtn; // 选中视图的按钮
    UIButton *_selectWidthBtn; // 选中宽度的按钮
    NSInteger _lineWidth; // 当前线条的宽度
    UIButton *_lineWidthBtn; // 显示当前线条宽度的按钮
    UISlider *_lineWidthSlider; // 显示当前线条宽度的滑块
    UIButton *_addBtn; // 增加宽度按钮
    UIButton *_removeBtn; // 减少宽度按钮
    UIView *_colorIndicator; // 选择线条显示的指示器
    UIButton *_eraserBtn; // 橡皮按钮
    UIButton *_defaultColorBtn; // 默认颜色按钮
    UIColor *_lineColor; // 当前线条的颜色
    UIColor *_eraserColor; // 切换橡皮的时候线条颜色
    GraphicsState _eraserState; // 切换橡皮的时候线条样式
}
// 保存点的位置数组
static NSMutableArray *_pointArray;
// 保存线条数组
static NSMutableArray *_lineArray;
// 保存线条样式数组
static NSMutableArray *_GraphicsStateArray;
// 保存撤销线条的数组
static NSMutableArray *_UndoLineArray;
// 保存返回上一步线条的数组
static NSMutableArray *_BackLineArray;
// 存储线条宽度的数组
static NSMutableArray *_WidthArray;
// 存储返回上一步线条宽度的数组
static NSMutableArray *_BackWidthArray;
// 存储线条宽度按钮的数组
static NSMutableArray *_WidthBtnArray;
static NSMutableArray *_ColorArray;
static NSMutableArray *_BackColorArray;


#pragma mark ~~~~~~~~~~ 初始化 ~~~~~~~~~~
+ (void)initialize {
    _pointArray = [NSMutableArray array];
    _lineArray = [NSMutableArray array];
    _GraphicsStateArray = [NSMutableArray array];
    _UndoLineArray = [NSMutableArray array];
    _BackLineArray = [NSMutableArray array];
    _WidthArray = [NSMutableArray array];
    _BackWidthArray = [NSMutableArray array];
    _WidthBtnArray = [NSMutableArray array];
    _ColorArray = [NSMutableArray array];
    _BackColorArray = [NSMutableArray array];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self initCustom];

    }
    return self;
}

- (void)initCustom {
    _state = noState; // 默认无样式
    _index = _state; // 默认0
    _lineWidth = 1; // 默认线条宽度为1
    _lineColor = [UIColor blackColor]; // 默认黑色
    
    // 添加点击手势
    self.userInteractionEnabled = YES;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:_tap];
    
    // 添加拖动手势
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:_pan];
    
    // 添加头部工具栏
    [self initHeadToolBar];
    
    // 添加底部工具视图
    [self initFootToolView];
    
}

- (void)initHeadToolBar {
    // 头部工具栏
    _headTool = [[UIView alloc] init];
    [self addSubview:_headTool];

    NSArray *array = @[@"无",@"直线",@"方形",@"圆形",@"保存",@"撤销",@"返回",@"清屏"];
    
    for (int i=0; i<array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 100+i;
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button addTarget:self action:@selector(headButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(Width/array.count * i, 20, Width/array.count, 44)];
        if (i == 4 || i == 7) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else if (i < 4) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
            if (i==0) {
                [self headButtonClick:button];
            }
        } else {
            if (i==5) {
                _undo = button;
            } else if (i==6) {
                _back = button;
            }
        }
        [_headTool addSubview:button];
    }
    
    // 查看是否可以撤回返回
    [self showUndoOrBackState];
}

- (void)initFootToolView {
    _footTool = [[UIView alloc] init];
    [self addSubview:_footTool];
    
    // 初始化线条颜色视图
    [self initLineColorView];
    
    // 初始化线条宽度视图
    [self initLineWidthView];
    
    // 初始化底部选择按钮视图
    [self initSelectView];
    
}

- (void)initLineColorView {
    CGFloat pageControllerH = (FootToolHeight-buttonH)/8;
    CGFloat indicatorH = 6;
    CGFloat columnMargin = 10;
    CGFloat colorBtnH = ((FootToolHeight-buttonH) - pageControllerH - indicatorH*2 - columnMargin*2)/2;
    CGFloat rowMargin = (Width-colorBtnH*6) / 7;
    
    _lineColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, FootToolHeight-buttonH)];
    _lineColorView.backgroundColor = [UIColor colorWithWhite:250/255.f alpha:1.0];
    [_footTool addSubview:_lineColorView];
    
    // 计算一个需要多个块(一个默认，一个橡皮擦)
    NSInteger count = [UIColor getColorArray].count + 2;
    // 计算有多少页
    NSInteger pageCount = count / 12 + 1;
    
    // 初始化线条颜色滚动视图
    _lineColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Width, FootToolHeight-buttonH-pageControllerH)];
    _lineColorScrollView.showsVerticalScrollIndicator = NO;
    _lineColorScrollView.showsHorizontalScrollIndicator = NO;
    _lineColorScrollView.pagingEnabled = YES;
    _lineColorScrollView.bounces = NO;
    _lineColorScrollView.delegate = self;
    _lineColorScrollView.contentSize = CGSizeMake(Width * pageCount, FootToolHeight-buttonH-pageControllerH);
    [_lineColorView addSubview:_lineColorScrollView];
    
    // 初始化线条指示器
    _colorIndicator = [[UIView alloc] init];
    _colorIndicator.backgroundColor = [UIColor redColor];
    _colorIndicator.h = indicatorH-2;
    _colorIndicator.w = colorBtnH/2;
    [_lineColorScrollView addSubview:_colorIndicator];
    
    // 创建颜色按钮
    for (int i=0; i<count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i+20;
        [button.layer setMasksToBounds:YES];
        [button.layer setBorderWidth:1.0];
        [button.layer setCornerRadius:colorBtnH/2];
        if (i==0) {
            [button setBackgroundColor:_lineColor];
            _defaultColorBtn = button;
        }
        if (i==1) {
            [button.layer setBorderColor:[UIColor whiteColor].CGColor];
            [button setBackgroundImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
            _eraserBtn = button;
        }
        if (i>1) {
            [button setBackgroundColor:(UIColor *)[UIColor getColorArray][i-2]];
        }

        [button addTarget:self action:@selector(selectLineColor:) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(rowMargin+(rowMargin+colorBtnH)*(i%6)+Width*(i/12), columnMargin+(columnMargin+colorBtnH+3)*(i%12/6), colorBtnH, colorBtnH)];
        
        if (i==2) {
            _colorIndicator.centerx = button.centerx;
            _colorIndicator.y = columnMargin+(columnMargin+colorBtnH)*(i%12/6) + colorBtnH+ 2;
        }
        
        [_lineColorScrollView addSubview:button];
    }

    
    // 初始化滚动视图指示器
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, FootToolHeight-buttonH-pageControllerH, Width, pageControllerH)];
    _pageControl.numberOfPages = pageCount;
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [_lineColorView addSubview:_pageControl];
}

- (void)initLineWidthView {
    NSArray *array = @[@"1",@"1",@"2",@"5",@"10",@"20"];
    
    _lineWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, FootToolHeight-buttonH)];
    _lineWidthView.backgroundColor = [UIColor colorWithWhite:250/255.f alpha:1.0];
    [_footTool addSubview:_lineWidthView];
    
    CGFloat padding = Width / 13;
    CGFloat margin = (Width-padding*2) / 11;
    CGFloat buttonW =( Width-(array.count+1)*padding)/array.count;
    for (int i=0; i<array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [button setFrame:CGRectMake(padding+(buttonW+margin)*i, padding/3, buttonW, buttonW)];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:buttonW/2];
        [button.layer setBorderWidth:1.0];
        button.tag = i+10;
        [button addTarget:self action:@selector(selectWidthClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor blackColor]];
            _lineWidthBtn = button;
        } else if (i==1) {
            [self selectWidthClick:button];
        }
        [_lineWidthView addSubview:button];
        [_WidthBtnArray addObject:button];
    }
    CGFloat sliderH = FootToolHeight-buttonW-buttonH-padding/3;
    // 初始化显示当前线条的滑块
    _lineWidthSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding*2, buttonW+padding/3, Width-padding*3-buttonW, sliderH)];
    _lineWidthSlider.minimumValue = 1;
    _lineWidthSlider.maximumValue = 20;
    _lineWidthSlider.value = _lineWidth;
    _lineWidthSlider.minimumTrackTintColor = [UIColor blackColor];
    _lineWidthSlider.thumbTintColor = [UIColor darkGrayColor];
    [_lineWidthSlider addTarget:self action:@selector(lineWidthChange:) forControlEvents:UIControlEventValueChanged];
    [_lineWidthView addSubview:_lineWidthSlider];
    
    // 初始化加减按钮
    _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonW+padding/3, padding*2, sliderH)];
    [_removeBtn setTitle:@"-" forState:UIControlStateNormal];
    [_removeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_removeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_removeBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_lineWidthView addSubview:_removeBtn];
    
    _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(Width-padding-buttonW, buttonW+padding/3, padding*2, sliderH)];
    [_addBtn setTitle:@"+" forState:UIControlStateNormal];
    [_addBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_addBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_lineWidthView addSubview:_addBtn];
}

- (void)initSelectView {
    NSArray *array = @[@"颜色",@"宽度"];
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, FootToolHeight-buttonH, Width, buttonH)];
    _selectView.backgroundColor = [UIColor whiteColor];
    [_footTool addSubview:_selectView];
    
    for (int i=0; i<array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [button setFrame:CGRectMake(Width/array.count * i, 0, Width/array.count, buttonH)];
        [button addTarget:self action:@selector(selectViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectView addSubview:button];
        if (i==0) {
            [self selectViewClick:button];
        }
    }
}

#pragma mark ~~~~~~~~~~ 布局 ~~~~~~~~~~
- (void)layoutSubviews {
    [super layoutSubviews];
    _headTool.frame = CGRectMake(0, -HeadToolHeight, Width, HeadToolHeight);
    _footTool.frame = CGRectMake(0, Height, Width, FootToolHeight);
}

#pragma mark ~~~~~~~~~~ 点击手势 ~~~~~~~~~~
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (point.y < Height/3) {
        [self openOrCloseHeadToolBar];
    } else if (point.y > Height/3*2) {
        [self openOrCloseFootToolBar];
    } else {
        [self dimissHeadToolView];
        [self dimissFootToolView];
    }
}

// 是否打开头部工具栏
- (void)openOrCloseHeadToolBar {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _headTool.frame;
        if (frame.origin.y == 0)  frame.origin.y = -64;
        else frame.origin.y = 0;
        _headTool.frame = frame;
    }];
}

// 隐藏头部工具栏
- (void)dimissHeadToolView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _headTool.frame;
        if (frame.origin.y == 0)  frame.origin.y = -64;
        _headTool.frame = frame;
    }];
}

// 是否打开底部工具栏
- (void)openOrCloseFootToolBar {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _footTool.frame;
        if (frame.origin.y == Height)  frame.origin.y = Height-FootToolHeight;
        else frame.origin.y = Height;
        _footTool.frame = frame;
    }];
}

// 隐藏底部工具栏
- (void)dimissFootToolView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _footTool.frame;
        if (frame.origin.y == Height-FootToolHeight)  frame.origin.y = Height;
        _footTool.frame = frame;
    }];
}

// 图片长按手势
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
}


#pragma mark ~~~~~~~~~~ 绘制图形 ~~~~~~~~~~
static CGContextRef _context;
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 获取图形上下文
    _context = UIGraphicsGetCurrentContext();
    // 设置线条的样式
    CGContextSetLineCap(_context, kCGLineCapRound);
    // 设置线条转角样式
    CGContextSetLineJoin(_context, kCGLineJoinRound);
    
    // 判断之前是否有线条需要重绘
    if (_lineArray.count > 0) {
        for (int i=0; i<_lineArray.count; i++) {
            // 取出第i个线重新绘制
            NSArray *array = _lineArray[i];
            [self drawLineWithPointArray:array WithIndex:i];
        }
    }
    // 绘制当前线条(没有线条传-1)
    [self drawLineWithPointArray:_pointArray WithIndex:-1];
}

// 画图形
- (void)drawLineWithPointArray:(NSArray *)array WithIndex:(int)i {
    GraphicsState state;
    NSInteger currentLineWidth = 0;
    UIColor *currentColor;
    // 设置线条的样式
    if (i >= 0) {
        // 取出第i个的图形样式(不能直接转化成枚举，数组存储的是对象)
        state = (GraphicsState)[_GraphicsStateArray[i] integerValue];
        currentLineWidth = [[_WidthArray objectAtIndex:i] integerValue];
        currentColor = [_ColorArray objectAtIndex:i];
    } else {
        state = _state;
        currentColor = _lineColor;
    }
    
    // 设置线条的宽度
    if (currentLineWidth > 0) {
        CGContextSetLineWidth(_context, currentLineWidth/1.0);
    } else {
        CGContextSetLineWidth(_context, _lineWidth/1.0);
    }
    
    // 设置线条的颜色
    if (currentColor) {
        CGContextSetStrokeColorWithColor(_context, [currentColor CGColor]);
    } else {
        CGContextSetStrokeColorWithColor(_context, [_lineColor CGColor]);
    }
    
    if (array.count > 0) {
        // 开始绘制
        CGContextBeginPath(_context);
        // 获取线条的开始点
        CGPoint startPoint = CGPointFromString(array[0]);
        // 绘制起点
        CGContextMoveToPoint(_context, startPoint.x, startPoint.y);
        if (state == lineState) { // 直线绘制
            CGPoint endPoint = CGPointFromString(array[array.count-1]);
            // 绘制终点
            CGContextAddLineToPoint(_context, endPoint.x, endPoint.y);
        } else if (state == squareState) { // 方形绘制
            CGPoint endPoint = CGPointFromString(array[array.count-1]);
            // 绘制终点
            CGContextAddRect(_context, CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y));
        } else if (state == roundState) { // 圆形绘制
            CGPoint endPoint = CGPointFromString(array[array.count-1]);
            // 绘制终点
            CGContextAddEllipseInRect(_context, CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y));
        } else {
            // 获取线条的最后一个点
            for (int i=0; i<array.count-1; i++) {
                CGPoint endPoint = CGPointFromString(array[i]);
                // 绘制终点
                CGContextAddLineToPoint(_context, endPoint.x, endPoint.y);
            }
        }
        // 保存绘制的线条
        CGContextStrokePath(_context);
    }
}

#pragma mark ~~~~~~~~~~ 屏幕事件 ~~~~~~~~~~
// 手指在屏幕上移动时调用
static CGPoint _handPoint;
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged || pan.state == UIGestureRecognizerStateBegan) {
        // 隐藏头部工具栏
        [self dimissHeadToolView];
        [self dimissFootToolView];
        
        // 获取手指移动的位置
        _handPoint = [pan locationInView:self];
        // 将位置保存到数组中
        [_pointArray addObject:NSStringFromCGPoint(_handPoint)];
        // 绘制图形
        [self setNeedsDisplay];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        // 把刚画的线条颜色保存到数组中
        [_ColorArray addObject:_lineColor];
        // 把刚画的线条宽度保存到数组中
        [_WidthArray addObject:@(_lineWidth)];
        // 把刚画的图形样式保存到数组中
        [_GraphicsStateArray addObject:@(_index)];
        // 把刚画的图形保存到线条数组中
        NSArray *array = [NSArray arrayWithArray:_pointArray];
        [_lineArray addObject:array];
        // 清空当前点的位置数组,以便重新绘制图形
        [_pointArray removeAllObjects];
        // 判断是否可以撤销返回
        [self showUndoOrBackState];
    }
}

#pragma mark ~~~~~~~~~~ 头部工具栏事件 ~~~~~~~~~~
-  (void)headButtonClick:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (index == 4) { // 保存
        [self save];
    } else if (index == 7) { // 清屏
        [self clear];
    } else if (index < 4) { // 样式选择
        _selectState.enabled = YES;
        button.enabled = NO;
        _selectState = button;
        
        _state = (GraphicsState)index;
        _index = _state;
    } else { // 撤销 返回
        [self undoOrBackClick:index];
    }
}

// 撤销返回点击事件
- (void)undoOrBackClick:(NSInteger)index {
    if (index == 5) {// 撤销
        if (_lineArray.count == 0) return;
        NSArray *lastLine = [_lineArray objectAtIndex:_lineArray.count-1];
        [_lineArray removeObjectAtIndex:_lineArray.count-1];
        [_BackLineArray addObject:lastLine];
        
        NSArray *lastWidth = [_WidthArray objectAtIndex:_WidthArray.count-1];
        [_WidthArray removeObjectAtIndex:_WidthArray.count-1];
        [_BackWidthArray addObject:lastWidth];
        
        NSArray *lastColor = [_ColorArray objectAtIndex:_ColorArray.count-1];
        [_ColorArray removeObjectAtIndex:_ColorArray.count-1];
        [_BackColorArray addObject:lastColor];
        
        [self setNeedsDisplay];
    } else if (index == 6) {// 返回
        if (_BackLineArray.count == 0) return;
        [_lineArray addObject:[_BackLineArray objectAtIndex:_BackLineArray.count-1]];
        [_BackLineArray removeObjectAtIndex:_BackLineArray.count-1];
        
        [_WidthArray addObject:[_BackWidthArray objectAtIndex:_BackWidthArray.count-1]];
        [_BackWidthArray removeObjectAtIndex:_BackWidthArray.count-1];
        
        [_ColorArray addObject:[_BackColorArray objectAtIndex:_BackColorArray.count-1]];
        [_BackColorArray removeObjectAtIndex:_BackColorArray.count-1];
        
        [self setNeedsDisplay];
    }
    [self showUndoOrBackState];
}

// 展现是否可以撤销返回
- (void)showUndoOrBackState {
    if (_lineArray.count > 0) {
        [_undo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [_undo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    if (_BackLineArray.count > 0) {
        [_back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [_back setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

// 保存
- (void)save {
    [self dimissHeadToolView];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存图像" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField becomeFirstResponder];
        textField.placeholder = @"请输入图像名";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveDocument:alert.textFields.firstObject.text];
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)saveDocument:(NSString *)name {
    // 需要切屏的尺寸
    UIGraphicsBeginImageContext(self.bounds.size);
    // 当前图形
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    // 创建图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束
    UIGraphicsEndImageContext();

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存图像" message:@"是否需要保存到相册？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"不需要" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 保存到沙盒
        [self saveDocument:image name:name];
        
        UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"成功" message:@"保存图片成功" preferredStyle:UIAlertControllerStyleAlert];
        [alert2 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert2 animated:YES completion:nil];

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"需要" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        // 保存到沙盒
        [self saveDocument:image name:name];
        
        // 保存到相册
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)saveDocument:(UIImage *)image name:(NSString *)name {
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemanage = [NSFileManager defaultManager];
    // 创建目录
    NSString *createPath = [NSString stringWithFormat:@"%@/image",document];
    if (![filemanage fileExistsAtPath:createPath]) {
        [filemanage createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 创建文件
    NSString *path = [createPath stringByAppendingPathComponent:name];
    if (![filemanage fileExistsAtPath:path]) {
        [filemanage createFileAtPath:path contents:nil attributes:nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:path atomically:YES];
    
    NSString *pathArray = [NSString stringWithFormat:@"%@/imagePathArray.plist",createPath];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:pathArray];
    // 调整位置
    NSMutableArray *array2 = [NSMutableArray array];
    [array2 addObject:name];
    [array2 addObjectsFromArray:array];
    [array2 writeToFile:pathArray atomically:YES];
}

// 图片存放到相册后的通知
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message;
    NSString *title;
    if (!error) {
        title = @"成功";
        message = @"保存图片成功!";
    } else {
        title = @"失败";
        message = @"保存图片失败!";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

// 清屏
- (void)clear {
    [self showUndoOrBackState];
    [self dimissHeadToolView];
    
    [_lineArray removeAllObjects];
    [_GraphicsStateArray removeAllObjects];
    [_pointArray removeAllObjects];
    [_UndoLineArray removeAllObjects];
    [_BackLineArray removeAllObjects];
    [_WidthArray removeAllObjects];
    [_ColorArray removeAllObjects];
    [_BackColorArray removeAllObjects];
    [self setNeedsDisplay];
    
    [self showUndoOrBackState];
}

#pragma mark ~~~~~~~~~~ 底部工具选择按钮点击事件 ~~~~~~~~~~
// 选择底部工具视图
- (void)selectViewClick:(UIButton *)button {
    _selectViewBtn.enabled = YES;
    [_selectViewBtn setBackgroundColor:[UIColor whiteColor]];
    button.enabled = NO;
    [button setBackgroundColor:[UIColor colorWithWhite:240/255.f alpha:1.0]];
    _selectViewBtn = button;
    
    if (button.tag == 0) {
        [_footTool bringSubviewToFront:_lineColorView];
    } else if (button.tag == 1) {
        [_footTool bringSubviewToFront:_lineWidthView];
    } 
}

// 选择线条的颜色
- (void)selectLineColor:(UIButton *)button {
    if (button == _eraserBtn) {
        if (button.layer.borderColor == [UIColor whiteColor].CGColor) {
            [button.layer setBorderColor:[UIColor redColor].CGColor];
            _eraserColor = _lineColor;
            _eraserState = _state;
            
            _lineColor = [UIColor whiteColor];
            _state = noState;
        } else {
            [button.layer setBorderColor:[UIColor whiteColor].CGColor];
            _lineColor = _eraserColor;
            _state = _eraserState;
        }
    }
    
    if (button.tag > 21) {
        [UIView animateWithDuration:0.25 animations:^{
            _colorIndicator.centerx = button.centerx;
            _colorIndicator.y = button.y + button.h + 2;
        }];
        [_defaultColorBtn setBackgroundColor:(UIColor *)[UIColor getColorArray][button.tag-22]];
        _lineColor = (UIColor *)[UIColor getColorArray][button.tag-22];
    }
}

// 选择线条的宽度
- (void)selectWidthClick:(UIButton *)button {
    if (button == _lineWidthBtn) return;
    
    _selectWidthBtn.enabled = YES;
    [_selectWidthBtn setBackgroundColor:[UIColor whiteColor]];
    button.enabled = NO;
    [button setBackgroundColor:[UIColor blackColor]];
    _selectWidthBtn = button;
    
    // 确定当前宽度
    NSInteger width = [button.currentTitle integerValue];
    _lineWidth = width;
    // 改变当前宽度显示
    [_lineWidthBtn setTitle:[NSString stringWithFormat:@"%zd",_lineWidth] forState:UIControlStateNormal];
    _lineWidthSlider.value = _lineWidth;
}

// 加减
- (void)buttonClick:(UIButton *)button {
    if (button == _addBtn) {// 加
        if (_lineWidth<20) {
            _lineWidth += 1;
        }
    } else if (button == _removeBtn) {// 减
        if (_lineWidth>1) {
            _lineWidth -= 1;
        }
    }
    // 改变当前宽度显示
    _lineWidthSlider.value = _lineWidth;
    [_lineWidthBtn setTitle:[NSString stringWithFormat:@"%zd",_lineWidth] forState:UIControlStateNormal];
    for (int i=1; i<_WidthBtnArray.count; i++) {
        UIButton *button = _WidthBtnArray[i];
        if (_lineWidth == [button.currentTitle integerValue]) {
            [self selectWidthClick:button];
            return;
        }
    }
}

// 滑块的值改变
- (void)lineWidthChange:(UISlider *)slider {
    _lineWidth = slider.value;
    // 改变当前宽度显示
    [_lineWidthBtn setTitle:[NSString stringWithFormat:@"%zd",_lineWidth] forState:UIControlStateNormal];
    for (int i=1; i<_WidthBtnArray.count; i++) {
        UIButton *button = _WidthBtnArray[i];
        if (_lineWidth == [button.currentTitle integerValue]) {
            [self selectWidthClick:button];
            return;
        }
    }
}

#pragma mark ~~~~~~~~~~ ScrollViewDelegae ~~~~~~~~~~
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.w;
    _pageControl.currentPage = index;
}


@end
