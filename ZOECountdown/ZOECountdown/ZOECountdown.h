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
    CountdownMode_longS,//直接显示几秒，前面不补'0'
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
- (instancetype)initWithTimeOut:(NSInteger)timeOut
                  countdownMode:(CountdownMode)countdownMode
                     timerBlock:(void (^)(NSString *remainTime))countdowning
                   endCountdown:(void (^)(void))endCountdown;

/// 倒计时
/// @param timeOut 倒计时秒数
/// @param interval 倒计时间隔默认是1秒执行一次
/// @param countdownMode 倒计时显示的模式
/// @param countdowning 倒计时进行中block
/// @param endCountdown 倒计时结束block
- (instancetype)initWithTimeOut:(NSInteger)timeOut
                       interval:(CGFloat)interval
                  countdownMode:(CountdownMode)countdownMode
                     timerBlock:(void (^)(NSString *remainTime))countdowning
                   endCountdown:(void (^)(void))endCountdown;

/// 计时（顺着累加计时）
/// @param time 初始时间单位秒
/// @param interval 执行的时间间隔，默认1秒
/// @param countdownMode 显示的模式
/// @param countdowning 进行中block
/// @param endCountdown 结束block
- (instancetype)initWithTime:(NSInteger)time
                    interval:(CGFloat)interval
               countdownMode:(CountdownMode)countdownMode
                  timerBlock:(void (^)(NSString *remainTime))countdowning
                endCountdown:(void (^)(void))endCountdown;


/// 退到后台是否挂起倒计时，YES：需要挂起  NO：不挂起 。 默认YES
@property (nonatomic,assign) BOOL observeApplicationActionNotification;

//倒计时挂起
- (void)suspendTimer;

//恢复倒计时
- (void)resumeTimer;

/// 取消倒计时队列
- (void)removeCountdown;

@end
