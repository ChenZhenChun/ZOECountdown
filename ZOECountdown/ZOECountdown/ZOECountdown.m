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
@property (nonatomic)         void(^Mycountdowning)(NSString *remainTime);
@property (nonatomic)         void(^MyEndcountdown)(void);
@property (nonatomic,assign)  NSInteger countdownMode;
@property (nonatomic, assign) NSTimeInterval timestamp;
@end

@implementation ZOECountdown


- (instancetype)initWithTimeOut:(NSInteger)timeOut
                  countdownMode:(CountdownMode)countdownMode
                     timerBlock:(void (^)(NSString *remainTime))countdowning
                   endCountdown:(void (^)(void))endCountdown {
    self = [super init];
    if (self) {
        _timeout = timeOut;
        _Mycountdowning = countdowning;
        _MyEndcountdown = endCountdown;
        _countdownMode  = countdownMode;
        [self observeApplicationActionNotification];
        [self startTimer];
    }
    return self;
}

- (dispatch_source_t)timer {
    if(!_timer) {
        __block NSString *time;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if(self.timeout<0) { //倒计时结束，关闭
                [self endTimer];
            } else {
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
            }
        });
    }
    return _timer;
}

- (void)startTimer {
    dispatch_resume(self.timer);
}

- (void)endTimer {
    [self removeCountdown];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.MyEndcountdown();
    });
}

- (void)observeApplicationActionNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
    if (self.timeout>=0) {
        self.timestamp = [NSDate date].timeIntervalSince1970+1;
        dispatch_suspend(_timer);
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
    if (_timer){
        if (@available(iOS 8.0, *)) {
            dispatch_cancel(_timer);
        }
    }
    _timer = nil;
}

@end
