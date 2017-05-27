//
//  QXBarrageView.h
//  QXBarrageView
//
//  Created by 孟庆祥 on 2017/5/26.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//


//弹幕的几个注意事项
//1.开始移动的时间到了
//2.不能碰撞   开始不能碰撞，结束的时候不能碰撞

#import <UIKit/UIKit.h>
#import "QXBarrageModelProtocol.h"
@protocol QXBarrageDelegate <NSObject>

@required
@property(nonatomic,assign,readonly)NSTimeInterval currentTime;

-(UIView*)getBarrageView:(id<QXBarrageModelProtocol>)model;
-(void)clickWithBarrage:(UIView*)view point:(CGPoint)point;
@end

@interface QXBarrageView : UIView
@property(nonatomic,weak)id<QXBarrageDelegate>delegate;
@property(nonatomic,strong)NSMutableArray <id <QXBarrageModelProtocol>>*barrageArray;//将弹幕model放入弹幕数组
-(void)pause;
-(void)resume;
@end
