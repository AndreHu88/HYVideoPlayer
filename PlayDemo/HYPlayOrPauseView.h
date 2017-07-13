//
//  HYPlayOrPauseView.h
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYPlayOrPauseView;
@protocol HYPlayOrPauseViewDelegate <NSObject>

/**
    播放暂停状态的改变
 */
- (void)playOrPauseView:(HYPlayOrPauseView *)view withState:(BOOL)isPlay;

@end

@interface HYPlayOrPauseView : UIView

/** 播放暂停按钮 */
@property (nonatomic,strong) UIButton *playOrPauseBtn;

/** 是否正在播放 */
@property (nonatomic,assign) BOOL isPlay;

/** 播放暂停回传代理 */
@property (nonatomic,weak) id<HYPlayOrPauseViewDelegate>delegate;

@end
