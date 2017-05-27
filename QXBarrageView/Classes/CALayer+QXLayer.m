//
//  CALayer+QXLayer.m
//  QXBarrageView
//
//  Created by 孟庆祥 on 2017/5/27.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "CALayer+QXLayer.h"

@implementation CALayer (QXLayer)
-(void)pause
{
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() toLayer:nil];
    self.speed = 0.0;
    self.timeOffset  = pausedTime;
}


-(void)resume
{
    CFTimeInterval pausedTime = self.timeOffset;
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timePause = [self convertTime:CACurrentMediaTime() toLayer:nil] - pausedTime;
    self.beginTime = timePause;
}
@end
