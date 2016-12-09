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
@property (nonatomic)         void(^MyEndcountdown)();
@property (nonatomic,assign)  NSInteger countdownMode;
@end

@implementation ZOECountdown


- (instancetype)initWithTimeOut:(NSInteger)timeOut countdownMode:(CountdownMode)countdownMode timerBlock:(void (^)(NSString *remainTime))countdowning endCountdown:(void (^)())endCountdown
{
    self = [super init];
    if (self) {
        _timeout = timeOut;
        _Mycountdowning = countdowning;
        _MyEndcountdown = endCountdown;
        _countdownMode  = countdownMode;
        [self startTimer];
    }
    return self;
}

- (dispatch_source_t)timer {
    if(!_timer){
        __block NSString *time;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(_timeout<=0){ //倒计时结束，关闭
                [self endTimer];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (_countdownMode) {
                        case CountdownMode_HH_mm_ss:
                            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)_timeout/3600,(long)_timeout%3600/60,(long)_timeout%60];
                            break;
                        case CountdownMode_mm_ss:
                            time = [NSString stringWithFormat:@"%02ld:%02ld",(long)_timeout/60,(long)_timeout%60];
                            break;
                        case CountdownMode_sss:
                            time = [NSString stringWithFormat:@"%03ld",(long)_timeout];
                            break;
                        case CountdownMode_ss:
                            time = [NSString stringWithFormat:@"%02ld",(long)_timeout];
                            break;
                        default:
                            break;
                    }
                    _Mycountdowning(time);
                });
                _timeout--;
            }
        });
    }
    return _timer;
}

- (void)startTimer{
    dispatch_resume(self.timer);
}

- (void)endTimer{
    dispatch_suspend(self.timer);
    dispatch_async(dispatch_get_main_queue(), ^{
        _MyEndcountdown();
    });
}

@end
