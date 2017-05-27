//
//  QXViewController.m
//  QXBarrageView
//
//  Created by mengqingxiang on 05/26/2017.
//  Copyright (c) 2017 mengqingxiang. All rights reserved.
//

#import "QXViewController.h"
#import "QXBarrageView.h"
#import "QXTestModel.h"
@interface QXViewController ()<QXBarrageDelegate>
@property(nonatomic,weak)QXBarrageView *barrageView;
@end

@implementation QXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    QXBarrageView *barrageView = [[QXBarrageView alloc]initWithFrame:CGRectMake(30, 100, 200, 100)];
    self.barrageView = barrageView;
    barrageView.backgroundColor = [UIColor orangeColor];
    barrageView.delegate = self;
    [self.view addSubview:barrageView];
}

- (IBAction)stop:(id)sender {
    [self.barrageView pause];
}


- (IBAction)goOn:(id)sender {
    [self.barrageView resume];
}
#pragma mark - QXBarrageDelegate

-(NSTimeInterval)currentTime
{
    static double time = 0;
    time +=0.1;
    return time;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    QXTestModel *mode = [[QXTestModel alloc]init];
    mode.barrageLiveTime = 3;
    mode.message = @"决定是否接受了";
    mode.beginTime = 2;
    
    
    QXTestModel *mode2 = [[QXTestModel alloc]init];
    mode2.barrageLiveTime = 5;
    mode2.message = @"决定是了";
    mode2.beginTime = 4;
    
    [self.barrageView.barrageArray addObject:mode];
    [self.barrageView.barrageArray addObject:mode2];
    
}

-(UIView *)getBarrageView:(QXTestModel<QXBarrageModelProtocol>*)model
{
    UILabel *lable = [[UILabel alloc]init];
    lable.text = model.message;
    [lable sizeToFit];
    return lable;
}

-(void)clickWithBarrage:(UIView *)view point:(CGPoint)point
{
    NSLog(@"%@",view,NSStringFromCGPoint(point));
}
@end
