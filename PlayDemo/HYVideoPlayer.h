//
//  HYVideoPlayer.h
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger , HYVideoPlayerStatus){
    
    HYVideoPlayerStatusFailed,
    HYVideoPlayerStatusReadyToPlay,
    HYVideoPlayerStatusUnkown,
    HYVideoPlayerStatusBuffering,
    HYVideoPlayerStatusPlaying,
    HYVideoPlayerStatusStop,
};

@interface HYVideoPlayer : UIView

/** player */
@property (nonatomic,strong) AVPlayer *player;

/** playerLayer */
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

/** 播放URL资产 */
@property (nonatomic,strong) AVURLAsset *asset;

/** 播放Item */
@property (nonatomic,strong) AVPlayerItem *item;

/** 视频文件的时长 */
@property (nonatomic,strong) NSString *AudioMins;

/** 播放状态 */
@property (nonatomic,assign) HYVideoPlayerStatus playStatus;

//用URL初始化
- (instancetype)initWIthUrl:(NSURL *)url;

//初始化播放View
//- (instancetype)initWithAsset:(AVURLAsset *)asset;

/** 播放 */
- (void)play;

/** 暂定 */
- (void)pause;

@end
