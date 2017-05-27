//
//  QXBarrageView.m
//  QXBarrageView
//
//  Created by 孟庆祥 on 2017/5/26.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXBarrageView.h"
#import "CALayer+QXLayer.h"
#define kTimeRepeateTime 0.1
#define kBarrageChannelMaxCount 5


@interface QXBarrageView()
{
    BOOL _isPause;
}
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSMutableArray *waitNextTime;
@property(nonatomic,strong)NSMutableArray *leftTime;
@property(nonatomic,strong)NSMutableArray *removeArray;
@property(nonatomic,strong)NSMutableArray *barrageViewArray;
@end
@implementation QXBarrageView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickEvent:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}


-(void)clickEvent:(UITapGestureRecognizer*)recognizer
{
    CGPoint tapPoint  = [recognizer locationInView:recognizer.view];
    for (UIView *barrageView in self.barrageViewArray) {
        CGRect barrageFrame = barrageView.layer.presentationLayer.frame;
        if (CGRectContainsPoint(barrageFrame, tapPoint)) {
            if ([self.delegate respondsToSelector:@selector(clickWithBarrage:point:)]) {
                [self.delegate clickWithBarrage:barrageView point:tapPoint];
            }
            break;
        }
    }
}

-(void)pause
{
    _isPause = YES;
    [[self.barrageViewArray valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(pause)];
    [self.timer invalidate];
    self.timer = nil;
}

-(void)resume
{
    if (!_isPause) return;
    _isPause = NO;
    [[self.barrageViewArray valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(resume)];
    [self timer];
}

-(void)checkBeginAndbiu
{
    if (_isPause == YES) {
        return;
    }
    //数据重置
    [self setUpData];
    
    //检测当前队列中开始时间最接近当前时间的model
    [self shortBeginTime];
    
    //检测找到最前面的begintime和当前time比较
    for (id<QXBarrageModelProtocol>model in self.barrageArray) {
        if (model.beginTime>self.delegate.currentTime) {//当前弹幕开始时间超过了当前的时间
            break;
        }
        
        //没超过可以发射出去，但是要检测是否会发生碰撞
        BOOL result  = [self checkSendAndbiu:model];
        if (result) {
            [self.removeArray addObject:model];
        }
    }
    
    [self.barrageArray removeObjectsInArray:self.removeArray];
    [self.removeArray removeAllObjects];
    
}


-(void)setUpData
{
    for (int i=0;i<kBarrageChannelMaxCount;i++) {
        NSTimeInterval waitTime = [self.waitNextTime[i] doubleValue]-0.1;
        self.waitNextTime[i] = @(waitTime<=0?0:waitTime);
        
        NSTimeInterval leftTime = [self.leftTime[i] doubleValue]-0.1;
        self.leftTime[i] = @(leftTime<=0?0:leftTime);
    }
}

-(BOOL)checkSendAndbiu:(id<QXBarrageModelProtocol>)model
{
    //查找弹道
    for (int i=0;i<kBarrageChannelMaxCount; i++) {
        NSTimeInterval waitTime = [self.waitNextTime[i] doubleValue];
        
        
        //为了开始的时候不放生碰撞
        if (waitTime>0) {
            continue;
        }
        
        
        UIView *barrageView = [self.delegate getBarrageView:model];
        
        NSTimeInterval leftTime = [self.leftTime[i] doubleValue];
        //获得弹幕的速度
        CGFloat width = barrageView.frame.size.width + self.frame.size.width;
        double speed = width/model.barrageLiveTime;
        if (speed *leftTime>self.frame.size.width) {//不能发射
            continue;
        }
        
        //重置数据
        self.waitNextTime[i] = @(barrageView.frame.size.width/speed);
        self.leftTime[i] = @(model.barrageLiveTime);
        
        [self sendBarrage:model index:i];
        return YES;
    }
    
    return NO;
}


-(void)sendBarrage:(id<QXBarrageModelProtocol>)model index:(int)index
{
    
    CGFloat Y = self.frame.size.height/(kBarrageChannelMaxCount+1)*index;
    
    UIView *view = [self.delegate getBarrageView:model];
    view.frame = CGRectMake(self.frame.size.width, Y, view.frame.size.width, view.frame.size.height);
    [self addSubview:view];
    [self.barrageViewArray addObject:view];
    
    [UIView animateWithDuration:model.barrageLiveTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        view.frame = CGRectMake(-view.frame.size.width, Y, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [self.barrageViewArray removeObject:view];
    }];
}

-(void)shortBeginTime
{
    [self.barrageArray sortedArrayUsingComparator:^NSComparisonResult(id<QXBarrageModelProtocol>  _Nonnull obj1, id<QXBarrageModelProtocol>  _Nonnull obj2) {
        return obj1.beginTime>obj2.beginTime?NSOrderedDescending:NSOrderedAscending;
    }];
}

#pragma mark -生命周期方法
-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self timer];
    self.layer.masksToBounds = YES;
}

-(void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

-(NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:kTimeRepeateTime target:self selector:@selector(checkBeginAndbiu) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

-(NSMutableArray *)barrageArray
{
    if (_barrageArray==nil) {
        _barrageArray = [NSMutableArray array];
    }
    return _barrageArray;
}

-(NSMutableArray *)waitNextTime
{
    if (_waitNextTime == nil) {
        _waitNextTime = [NSMutableArray array];
        for (int i =0 ; i<kBarrageChannelMaxCount; i++) {
            [_waitNextTime addObject:@(0.0)];
        }
    }
    return _waitNextTime;
}

-(NSMutableArray *)leftTime
{
    if (_leftTime == nil) {
        _leftTime = [NSMutableArray array];
        for (int i =0 ; i<kBarrageChannelMaxCount; i++) {
            [_leftTime addObject:@(0.0)];
        }
    }
    return _leftTime;
}

-(NSMutableArray *)removeArray
{
    if (_removeArray==nil) {
        _removeArray = [NSMutableArray array];
    }
    return _removeArray;
}

-(NSMutableArray *)barrageViewArray
{
    if (_barrageViewArray == nil) {
        _barrageViewArray = [NSMutableArray array];
    }
    return _barrageViewArray;
}
@end
