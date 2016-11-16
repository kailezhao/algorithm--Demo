//
//  ViewController.m
//  algorithm
//
//  Created by WT－WD on 16/11/16.
//  Copyright © 2016年 WT－WD. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+ZKLSort.h"

static const NSInteger kBarCount = 100;
@interface ViewController ()
@property(nonatomic,strong)UISegmentedControl *segmentControl;
@property(nonatomic,strong)UILabel *timeLabel;
    
@property(nonatomic,strong)NSMutableArray<UIView*> *barArray;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)dispatch_semaphore_t sema;//声明一个信号量

@end

@implementation ViewController
#pragma mark - 懒加载
-(UISegmentedControl *)segmentControl{
    if (!_segmentControl) {
       _segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"选择",@"冒泡",@"插入",@"快速",@"堆排序"]];
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(onSegmentControlChanged:) forControlEvents:(UIControlEventValueChanged)];
        _segmentControl.tintColor  = [UIColor orangeColor];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} forState:(UIControlStateNormal)];
        
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:(UIControlStateSelected)];
        
        [self.view addSubview:_segmentControl];
    }
    return _segmentControl;
}
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel =[[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor =[UIColor darkTextColor];
        _timeLabel.backgroundColor = [UIColor orangeColor];
        _timeLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_timeLabel];
    }
    return _timeLabel;
}
-(NSMutableArray<UIView *> *)barArray{
    if (!_barArray) {
        _barArray = [NSMutableArray arrayWithCapacity:kBarCount];
        for (int i = 0; i < kBarCount; i++) {
            UIView *bar = [[UIView alloc]init];
            bar.backgroundColor = [UIColor orangeColor];
            [self.view addSubview:bar];
            [_barArray addObject:bar];
        }
    }
    return _barArray;
}

    
#pragma mark - Left Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"算法";
    [self setUI];
}

-(void)setUI{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"重置" style:(UIBarButtonItemStylePlain) target:self action:@selector(onReset)];
    self.navigationItem.rightBarButtonItem  =[[UIBarButtonItem alloc]initWithTitle:@"排序" style:(UIBarButtonItemStylePlain) target:self action:@selector(onSort)];

    self.segmentControl.frame = CGRectMake(15, 64+10, CGRectGetWidth(self.view.bounds)-30, 30);
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * 0.5 - 50,
                                      CGRectGetHeight(self.view.bounds) * 0.8, 120, 40);
    [self onReset];//重置

}
    
    
#pragma mark - Action
-(void)onSegmentControlChanged:(UISegmentedControl*)segmentControl{
    [self onReset];
}
//重置
-(void)onReset{
    [self invalidateTimer];//初始化时间
    self.timeLabel.text = nil;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat barMargin = 1;
    CGFloat barWidth = floorf((width-barMargin*(kBarCount+1))/kBarCount);
    CGFloat barOrginX = roundf((width-(barMargin+barWidth)*kBarCount+barMargin)/2.0);
    CGFloat barAreaY = 64+10+30+10;
    CGFloat barButtom = CGRectGetHeight(self.view.bounds)*0.8;
    CGFloat barAreaHeight = barButtom-barAreaY;
    
    
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull bar, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat barHeight = 20+arc4random_uniform(barAreaHeight - 20)
        ;
        // 若需要制造高概率重复数据请打开此行，令数值为10的整数倍(或修改为其它倍数)
//        barHeight=roundf(barHeight/10)*10;
        bar.frame = CGRectMake(barOrginX+idx*(barMargin+barWidth), barButtom-barHeight, barWidth, barHeight);
    }];
    NSLog(@"重置成功");
    
    [self printBarArray];
}
//排序
-(void)onSort{
    [self invalidateTimer];
    self.sema = dispatch_semaphore_create(0);
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    //定时器信号
    __weak typeof(self) weakSelf = self;
    self.timer =[NSTimer scheduledTimerWithTimeInterval:0.002 repeats:YES block:^(NSTimer * _Nonnull timer) {
        //发出信号量,唤醒排序线程
        dispatch_semaphore_signal(weakSelf.sema);
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970]-nowTime;
        weakSelf.timeLabel.text= [NSString stringWithFormat:@"耗时(秒):%02.3f",interval];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0://选择排序
            {
                [self selectionSort];
            break;
            }
            case 1://冒泡排序
            {
                [self bubblingSort];
                break;
            }
            case 2://插入排序
            {
                [self insertSort];
                break;
            }
            case 3://快速排序
            {
                [self fastSort];
                break;
            }
            case 4://堆排序
            {
                [self heapSort];
                break;
            }
            default:
            break;
        }
        [self invalidateTimer];
        [self printBarArray];
    });
    
}
-(void)printBarArray{
#if 1
    NSMutableString *str = [NSMutableString string];
    
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@",@(CGRectGetHeight(obj.frame))];
    }];
    NSLog(@"数组：%@",str);
    
#endif
}
//初始化时间
-(void)invalidateTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.sema = nil;
}
#pragma mark - 排序
//选择排序
-(void)selectionSort{
    [self.barArray zkl_selectionSortComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 barTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
     [self exchangePositionWithBarOne:obj1 barTow:obj2];
    }];
}
//冒泡排序
-(void)bubblingSort{
    [self.barArray zkl_bubblingSortComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 barTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangePositionWithBarOne:obj1 barTow:obj2];
    }];
}
//插入排序
-(void)insertSort{
[self.barArray zkl_insertSortComparator:^NSComparisonResult(id obj1, id obj2) {
    return [self compareWithBarOne:obj1 barTwo:obj2];
} didExcahnge:^(id obj1, id obj2) {
    [self exchangePositionWithBarOne:obj1 barTow:obj2];
}];
}
//快速排序
-(void)fastSort{
    [self.barArray zkl_fastSortComparator:^NSComparisonResult(id obj1, id obj2) {
       return [self compareWithBarOne:obj1 barTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangePositionWithBarOne:obj1 barTow:obj2];
    }];
}
//堆排序
-(void)heapSort{
    [self.barArray zkl_heapSortComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 barTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangePositionWithBarOne:obj1 barTow:obj2];
    }];
}
-(NSComparisonResult)compareWithBarOne:(UIView*)barOne barTwo:(UIView *)barTwo{
    //模拟进行比较所需的耗时
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    
    CGFloat height1 = CGRectGetHeight(barOne.frame);
    CGFloat height2 = CGRectGetHeight(barTwo.frame);
    
    if (height1 == height2) {
        return NSOrderedSame;
    }
    
//    return height1 < height2 ? NSOrderedAscending : NSOrderedDescending;
    return height1 < height2 ? NSOrderedDescending : NSOrderedAscending;
    
}
-(void)exchangePositionWithBarOne:(UIView*)barOne barTow:(UIView*)barTow{
dispatch_async(dispatch_get_main_queue(), ^{
    CGRect frameOne =barOne.frame;
    CGRect frameTow = barTow.frame;
    
    frameOne.origin.x = barTow.frame.origin.x;
    frameTow.origin.x = barOne.frame.origin.x;
    
    barOne.frame = frameOne;
    barTow.frame = frameTow;
    
});
}
    
    
@end
