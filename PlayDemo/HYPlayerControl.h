//
//  HYPlayerControl.h
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HYPlayerControlDelegate <NSObject>

/** 视频的播放进度 */
- (void)playPregressChange:(CGFloat)progress;

/** 是否全屏 */
- (void)fullScreenOrHalfScreen:(BOOL)isFullScreen;

@end

@interface HYPlayerControl : UIView

/** 视频的时长 */
@property (nonatomic,copy) NSString *videoMins;

/** 当前时间 */
@property (nonatomic,copy) NSString *currentTime;

/** 缓存条进度 */
@property (nonatomic,assign) CGFloat bufferValue;

/** 进度条当前值 */
@property (nonatomic,assign) CGFloat currentValue;

/** 最小值 */
@property (nonatomic,assign) CGFloat minValue;

/** 最大值 */
@property (nonatomic,assign) CGFloat maxValue;

/** delegate */
@property (nonatomic,weak) id<HYPlayerControlDelegate>delegate;

@end
