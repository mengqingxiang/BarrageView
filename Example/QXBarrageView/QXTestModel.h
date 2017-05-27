//
//  QXTestView.h
//  QXBarrageView
//
//  Created by 孟庆祥 on 2017/5/27.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QXBarrageModelProtocol.h"
@interface QXTestModel : NSObject<QXBarrageModelProtocol>
@property(nonatomic,assign)NSTimeInterval barrageLiveTime;//弹幕的生存时间
@property(nonatomic,assign)NSTimeInterval beginTime;    //弹幕的开始时间
@property(nonatomic,copy)NSString *message;    //弹幕的开始时间
@end
