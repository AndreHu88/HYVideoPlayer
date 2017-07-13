//
//  HYVideoPlayer.m
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import "HYVideoPlayer.h"
#import "HYPlayerControl.h"
#import "HYPlayOrPauseView.h"

@interface HYVideoPlayer()<HYPlayOrPauseViewDelegate,HYPlayerControlDelegate>

/** 播放控制View */
@property (nonatomic,strong) HYPlayerControl *playerControl;

/** 播放暂停View */
@property (nonatomic,strong) HYPlayOrPauseView *playOrPauseView;

/** 追踪时间的变化 */
@property (nonatomic,strong) id timeObserverToken;

/** 加载View */
@property (nonatomic,strong) UIActivityIndicatorView *indicatiorView;

@end


static NSInteger count = 0;

@implementation HYVideoPlayer

- (instancetype)initWIthUrl:(NSURL *)url{
    
    if (self = [super init]) {
        
        [self assetWithUrl:url];
        self.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}

- (void)layoutSubviews{
    
    [self addSubview:self.playOrPauseView];
    [self addSubview:self.playerControl];
    [self addSubview:self.indicatiorView];

}

//- (instancetype)initWithAsset:(AVURLAsset *)asset{
//    
//    if (self = [super init]) {
//        
//        self.asset = asset;
//        
//        [self.layer addSublayer:self.playerLayer];
//        
//        [self setupAsset];
//        
//    }
//    
//    return self;
//}

- (void)assetWithUrl:(NSURL *)url{

    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    self.asset = [[AVURLAsset alloc] initWithURL:url options:options];
    self.item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.item];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerLayer displayIfNeeded];

    [self setupAsset];

    [self addKVO];
    [self addNotification];
    [self addPeriodicTimeObserver];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGes];
    
    [self.indicatiorView startAnimating];
}

- (void)dealloc{
    
    [self removeKVO];
    [self removeNotification];
}

- (void)setupAsset{
    
    NSArray *keys = @[@"duration"];
    
    __weak typeof (self) weakSelf = self;
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [weakSelf.asset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(weakSelf.asset.duration)) {
                        
                        CGFloat second = weakSelf.asset.duration.value / weakSelf.asset.duration.timescale;
                        weakSelf.playerControl.maxValue = second;
                        weakSelf.playerControl.videoMins = [weakSelf convertTimeStr:second];
                        weakSelf.playerControl.minValue = 0;
                        
                        [self layoutIfNeeded];
                    }
                });
            }
                break;
            case AVKeyValueStatusFailed:
            {
                NSLog(@"AVKeyValueStatusFailed");
            }
                break;
            case AVKeyValueStatusCancelled:{
                
                NSLog(@"AVKeyValueStatusCancelled");
            }
                break;
            case AVKeyValueStatusUnknown:{
                
                NSLog(@"AVKeyValueStatusUnknown");
            }
                break;
            case AVKeyValueStatusLoading:{
                
                NSLog(@"AVKeyValueStatusLoading");
            }
            default:
                break;
        }
    }];
}

#pragma mark - KVO
- (void)addKVO{
    
    //监听状态属性
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听播放器缓冲进度
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听播放的区域缓存是否为空
    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    //缓冲可以播放时调用
    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    if ([keyPath isEqualToString:@"status"]){
        
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (itemStatus) {
            case AVPlayerItemStatusFailed:
                _playStatus = HYVideoPlayerStatusFailed;
                break;
            case AVPlayerItemStatusReadyToPlay:
                _playStatus = HYVideoPlayerStatusReadyToPlay;
                break;
            case AVPlayerItemStatusUnknown:
                _playStatus = HYVideoPlayerStatusUnkown;
                break;
            default:
                break;
        }
        
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //播放器的下载进度
        NSArray *loaderTImeRanges = [self.item loadedTimeRanges];
        CMTimeRange timeRange = [[loaderTImeRanges firstObject] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        //计算缓冲总进度
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        CMTime duration = self.item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        self.playerControl.bufferValue = timeInterval / totalDuration;
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
        _playStatus = HYVideoPlayerStatusBuffering;
        if (!self.indicatiorView.isAnimating) {
            [self.indicatiorView startAnimating];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        
        NSLog(@"缓冲达到可以播放");
        [self.indicatiorView stopAnimating];
    }
    else if ([keyPath isEqualToString:@"rate"]){
        //当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 0) {

            _playStatus = HYVideoPlayerStatusStop;
        }
        else{
            
            _playStatus = HYVideoPlayerStatusPlaying;
        }
    }
}

- (void)removeKVO{
    
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.item removeObserver:self forKeyPath:@"rate"];
}

#pragma mark - Notification
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HYPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)HYPlayerItemDidPlayToEndTimeNotification:(NSNotificationCenter *)notificationCenter{

    [self.item seekToTime:kCMTimeZero];
    [self pause];
    
    self.playOrPauseView.playOrPauseBtn.selected = NO;
    
    count = 0;
}

- (void)deviceOrientationDidChange:(NSNotificationCenter *)notificationCenter{
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:{
        
            [UIView animateWithDuration:0.5 animations:^{
                
                self.frame = [UIApplication sharedApplication].keyWindow.bounds;
                [self layoutIfNeeded];
            }];
        }
        case UIInterfaceOrientationPortrait:{
            
            [UIView animateWithDuration:0.5 animations:^{
               
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                self.frame = CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.width / 2 + 40);
                [self layoutIfNeeded];
            }];
        }
            
        default:
            break;
    }
}

- (void)removeNotification{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Action
- (void)tapAction{

    count = 0;
    [self setSubViewsHidden:NO];
}


#pragma mark - Util
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

- (void)play{
    
    if (self.player) {
        
        [self.player play];
    }
}

- (void)pause{
    
    if (self.player) {
        
        [self.player pause];
    }
}

//设置播放器其他控件的隐藏
- (void)setSubViewsHidden:(BOOL)isHidden{
    
    self.playerControl.hidden = isHidden;
    self.playOrPauseView.hidden = isHidden;
}

//追踪时间的变化
- (void)addPeriodicTimeObserver {
        // Invoke callback every half second
        CMTime interval = CMTimeMakeWithSeconds(1.f, NSEC_PER_SEC);
        // Queue on which to invoke the callback
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
        __weak typeof (self) weakSelf = self;
        // Add time observer
        self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
           
            weakSelf.playerControl.currentValue = weakSelf.item.currentTime.value / weakSelf.item.currentTime.timescale;
            
            if (count >= 5) {
                [weakSelf setSubViewsHidden:YES];
            }
            else{
                [weakSelf setSubViewsHidden:NO];
            }
            
            count ++;
        }];
}

//旋转方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - delegate
- (void)playOrPauseView:(HYPlayOrPauseView *)view withState:(BOOL)isPlay{
    
    if (isPlay) {
        [self play];
    }
    else{
        [self pause];
    }
    
    count = 0;
}

#pragma mark - 播放控制Delegate
- (void)playPregressChange:(CGFloat)progress{
    
    CGFloat currentProgress = self.playerControl.maxValue * progress;
    self.playerControl.currentTime = [self convertTimeStr:currentProgress];
    
//    CMTime pointTime = CMTimeMake(currentProgress, self.item.currentTime.timescale);
//    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.item seekToTime:CMTimeMakeWithSeconds(currentProgress, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    count = 0;
}

- (void)fullScreenOrHalfScreen:(BOOL)isFullScreen{
    
    if (isFullScreen) {
        
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
    else{
        
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - Getter

- (AVPlayer *)player {
    
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

// Override UIView method
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    
    return (AVPlayerLayer *)self.layer;
}

- (HYPlayerControl *)playerControl{
    
    if (!_playerControl) {
        
        _playerControl = [[HYPlayerControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        _playerControl.backgroundColor = [UIColor clearColor];
        _playerControl.delegate = self;
        _playerControl.currentTime = @"00:00";
        _playerControl.videoMins = @"00:00";
    }
    return _playerControl;
}

- (HYPlayOrPauseView *)playOrPauseView{

    if (!_playOrPauseView) {
        
        _playOrPauseView = [[HYPlayOrPauseView alloc] initWithFrame:self.bounds];
        _playOrPauseView.backgroundColor = [UIColor clearColor];
        _playOrPauseView.delegate = self;
    }
    return _playOrPauseView;
}

- (UIActivityIndicatorView *)indicatiorView{

    if (!_indicatiorView) {
        _indicatiorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatiorView.frame = CGRectMake(0, 0, 80, 80);
        _indicatiorView.center = self.center;
        _indicatiorView.hidesWhenStopped = YES;
    }
    return _indicatiorView;
}

@end
