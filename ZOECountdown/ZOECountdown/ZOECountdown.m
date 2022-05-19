//
//  ZOECountdown.m
//  AiyoyouDemo
//
//  Created by aiyoyou on 16/4/18.
//  Copyright © 2016年 aiyoyou. All rights reserved.
//

#import "ZOECountdown.h"

@interface ZOECountdown()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic,assign) CGFloat interval;//间隔
@property (nonatomic)         void(^Mycountdowning)(NSString *remainTime);
@property (nonatomic)         void(^MyEndcountdown)(void);
@property (nonatomic,assign)  NSInteger countdownMode;
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic,assign) BOOL isSuspend;//timer是否挂起。dispatch_suspend 之后的Timer，是不能被释放的(timer=nil会导致崩溃)
@property (nonatomic,assign) BOOL isASC;//是否升序计数
@end

@implementation ZOECountdown


- (instancetype)initWithTimeOut:(NSInteger)timeOut
                  countdownMode:(CountdownMode)countdownMode
                     timerBlock:(void (^)(NSString *remainTime))countdowning
                   endCountdown:(void (^)(void))endCountdown {
    
    return [self initWithTimeOut:timeOut
                        interval:1
                   countdownMode:countdownMode
                      timerBlock:countdowning
                    endCountdown:endCountdown];
}

- (instancetype)initWithTimeOut:(NSInteger)timeOut
                       interval:(CGFloat)interval
                  countdownMode:(CountdownMode)countdownMode
                     timerBlock:(void (^)(NSString *))countdowning
                   endCountdown:(void (^)(void))endCountdown {
    self = [super init];
    if (self) {
        _timeout = timeOut;
        _interval = interval;
        _Mycountdowning = countdowning;
        _MyEndcountdown = endCountdown;
        _countdownMode  = countdownMode;
        _observeApplicationActionNotification = YES;
        [self applicationActionNotification];
        [self startTimer];
    }
    return self;
}

- (instancetype)initWithTime:(NSInteger)time
                    interval:(CGFloat)interval
               countdownMode:(CountdownMode)countdownMode
                  timerBlock:(void (^)(NSString *))countdowning
                endCountdown:(void (^)(void))endCountdown {
    self = [super init];
    if (self) {
        _isASC = YES;
        _timeout = time;
        _interval = interval;
        _Mycountdowning = countdowning;
        _MyEndcountdown = endCountdown;
        _countdownMode  = countdownMode;
        _observeApplicationActionNotification = YES;
        [self applicationActionNotification];
        [self startTimer];
    }
    return self;
}

- (dispatch_source_t)timer {
    if(!_timer) {
        __block NSString *time;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        if (self.interval<=0) {
            self.interval = 1;
        }
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),self.interval*NSEC_PER_SEC, 0);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (self.isASC) {
                if (self.Mycountdowning) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (self.countdownMode) {
                            case CountdownMode_HH_mm_ss:
                                time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.timeout/3600,(long)self.timeout%3600/60,(long)self.timeout%60];
                                break;
                            case CountdownMode_mm_ss:
                                time = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.timeout/60,(long)self.timeout%60];
                                break;
                            case CountdownMode_sss:
                                time = [NSString stringWithFormat:@"%03ld",(long)self.timeout];
                                break;
                            case CountdownMode_ss:
                                time = [NSString stringWithFormat:@"%02ld",(long)self.timeout];
                                break;
                            case CountdownMode_longS:
                                time = [NSString stringWithFormat:@"%ld",(long)self.timeout];
                                break;
                            default:
                                break;
                        }
                        self.Mycountdowning(time);
                        self.timeout++;
                    });
                }else {
                    self.timeout++;
                }
                
            }else {
                if(self.timeout<0) { //倒计时结束，关闭
                    [self endTimer];
                } else {
                    if (self.Mycountdowning) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            switch (self.countdownMode) {
                                case CountdownMode_HH_mm_ss:
                                    time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.timeout/3600,(long)self.timeout%3600/60,(long)self.timeout%60];
                                    break;
                                case CountdownMode_mm_ss:
                                    time = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.timeout/60,(long)self.timeout%60];
                                    break;
                                case CountdownMode_sss:
                                    time = [NSString stringWithFormat:@"%03ld",(long)self.timeout];
                                    break;
                                case CountdownMode_ss:
                                    time = [NSString stringWithFormat:@"%02ld",(long)self.timeout];
                                    break;
                                case CountdownMode_longS:
                                    time = [NSString stringWithFormat:@"%ld",(long)self.timeout];
                                break;
                                default:
                                    break;
                            }
                            self.Mycountdowning(time);
                            self.timeout--;
                        });
                    }else {
                        self.timeout--;
                    }
                    
                }
            }
            
        });
    }
    return _timer;
}

- (void)startTimer {
    [self resumeTimer];
}

- (void)endTimer {
    [self removeCountdown];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.MyEndcountdown) {
            self.MyEndcountdown();
        }
    });
}

//倒计时挂起
- (void)suspendTimer {
    self.isSuspend = YES;
    dispatch_suspend(_timer);
}

//恢复倒计时
- (void)resumeTimer {
    self.isSuspend = NO;
    dispatch_resume(self.timer);
}

- (void)applicationActionNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setObserveApplicationActionNotification:(BOOL)observeApplicationActionNotification {
    _observeApplicationActionNotification = observeApplicationActionNotification;
    if (_observeApplicationActionNotification) {
        [self applicationActionNotification];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)applicationDidEnterBackground {
    if (self.timeout>=0) {
        self.timestamp = [NSDate date].timeIntervalSince1970+1;
        [self suspendTimer];
    }
}

- (void)applicationDidBecomeActive {
    if (self.timeout>=0 && self.timestamp!=0) {
        NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970-self.timestamp; //进行时间差计算操作
        self.timestamp = 0;
        NSTimeInterval ret = _timeout - timeInterval;
        if (ret > 0) {
            _timeout = ret;
        } else {
            _timeout = 0;
        }
        self.timestamp = 0;
        [self startTimer];
    }
}
    
- (void)removeCountdown {
    if (self.isSuspend) [self startTimer];
    if (_timer){
        if (@available(iOS 8.0, *)) {
            dispatch_cancel(_timer);
        }
    }
    _timer = nil;
}

@end
