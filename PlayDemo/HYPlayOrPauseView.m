//
//  HYPlayOrPauseView.m
//  PlayDemo
//
//  Created by leimo on 2017/7/11.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import "HYPlayOrPauseView.h"

@implementation HYPlayOrPauseView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.playOrPauseBtn];
    }
    return self;
}

- (UIButton *)playOrPauseBtn{

    if (!_playOrPauseBtn) {
        
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseBtn.frame = self.frame;
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}


- (void)buttonAction:(UIButton *)sender{

    sender.selected = !sender.selected;
    self.isPlay = sender.selected;
    
    if (_delegate && [_delegate respondsToSelector:@selector(playOrPauseView:withState:)]) {
        
        [_delegate playOrPauseView:self withState:self.isPlay];
    }
}

@end
