//
//  ZOECountdown.h
//  AiyoyouDemo
//  倒计时
//  Created by aiyoyou on 16/4/18.
//  Copyright © 2016年 aiyoyou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CountdownMode_HH_mm_ss,//HH:mm:ss
    CountdownMode_mm_ss,//mm:ss
    CountdownMode_sss,//sss
    CountdownMode_ss,//ss
} CountdownMode;

@interface ZOECountdown : NSObject

/**
 倒计时

 @param timeOut 倒计时秒数
 @param countdownMode 倒计时显示的模式
 @param countdowning 倒计时进行中block
 @param endCountdown 倒计时结束block
 @return 控件实例
 */
- (instancetype)initWithTimeOut:(NSInteger)timeOut countdownMode:(CountdownMode)countdownMode timerBlock:(void (^)(NSString *remainTime))countdowning endCountdown:(void (^)())endCountdown;

@end
