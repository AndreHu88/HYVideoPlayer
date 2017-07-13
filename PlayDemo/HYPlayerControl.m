//
//  HYPlayerControl.m
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import "HYPlayerControl.h"
#import "UIViewExt.h"

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface HYPlayerControl()

/** 当前进度label */
@property (nonatomic,strong) UILabel *currentTimeLabel;

/** 总时间label */
@property (nonatomic,strong) UILabel *totalTimeLabel;

/** 播放精度条 */
@property (nonatomic,strong) UISlider *playProgress;

/** 缓冲进度条 */
@property (nonatomic,strong) UISlider *bufferProgress;

/** 全屏按钮 */
@property (nonatomic,strong) UIButton *fullScreenBtn;

@end

@implementation HYPlayerControl

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.currentTimeLabel];
        [self addSubview:self.bufferProgress];
        [self addSubview:self.playProgress];
        [self addSubview:self.totalTimeLabel];
        [self addSubview:self.fullScreenBtn];
        
    }
    return self;
}

#pragma mark - Setter
- (void)setCurrentTime:(NSString *)currentTime{
    
    _currentTime = currentTime;
    _currentTimeLabel.text = currentTime;
    
    _currentValue = [currentTime floatValue];
}

- (void)setVideoMins:(NSString *)videoMins{
    
    _videoMins = videoMins;
    _totalTimeLabel.text = videoMins;
}

- (void)setBufferValue:(CGFloat)bufferValue{
    
    _bufferValue = bufferValue;
    _bufferProgress.value = bufferValue;
}

- (void)setCurrentValue:(CGFloat)currentValue{
    
    _currentValue = currentValue;
    self.currentTime = [self convertTimeStr:currentValue];
    
    self.playProgress.value = currentValue / self.maxValue;
}

#pragma mark - Getter
- (UILabel *)currentTimeLabel{
    
    if (!_currentTimeLabel) {
        
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.frame.size.height)];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIButton *)fullScreenBtn{
    
    if (!_fullScreenBtn) {
        
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.frame = CGRectMake(kScreenWidth - 60, 0, 50, self.height);
        [_fullScreenBtn setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UILabel *)totalTimeLabel{
    
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.fullScreenBtn.left - 55, 0 ,  50, self.height)];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = self.videoMins;
    }
    return _totalTimeLabel;
}

- (UISlider *)playProgress{
    
    if (!_playProgress) {
        _playProgress = [[UISlider alloc] initWithFrame:CGRectMake(self.currentTimeLabel.right, 10, self.totalTimeLabel.left - self.currentTimeLabel.right - 5, self.height - 20)];
        _playProgress.value = 0;
        _playProgress.minimumTrackTintColor = [UIColor whiteColor];
        _playProgress.maximumTrackTintColor = [UIColor clearColor];
        [_playProgress setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
        [_playProgress addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _playProgress;
}


- (UISlider *)bufferProgress{
    
    if (!_bufferProgress) {
        
        _bufferProgress = [[UISlider alloc] initWithFrame:CGRectMake(self.currentTimeLabel.right, 10, self.totalTimeLabel.left - self.currentTimeLabel.right - 5, self.height - 20)];
        _bufferProgress.value = 0;
        _bufferProgress.minimumTrackTintColor = [UIColor redColor];
        _bufferProgress.maximumTrackTintColor = [UIColor clearColor];
        [_bufferProgress setThumbImage:[UIImage new] forState:UIControlStateNormal];
    }
    return _bufferProgress;
}

#pragma mark - Action
- (void)sliderChangeValue:(UISlider *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(playPregressChange:)]) {
        
        [_delegate playPregressChange:sender.value];
    }
    NSLog(@"%f",sender.value);
}

- (void)fullScreenBtnAction:(UIButton *)sender{

    if (_delegate && [_delegate respondsToSelector:@selector(fullScreenOrHalfScreen:)]) {
        
        [_delegate fullScreenOrHalfScreen:sender.selected];
    }
    sender.selected = !sender.selected;

}

#pragma mark - util
- (NSString *)convertTimeStr:(CGFloat)second{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    else{
        [formatter setDateFormat:@"mm:ss"];
    }
    
    return [formatter stringFromDate:date];
}

@end
