//
//  ViewController.m
//  PlayDemo
//
//  Created by leimo on 2017/7/10.
//  Copyright © 2017年 huyong. All rights reserved.
//

#import "ViewController.h"
#import "HYVideoPlayer.h"

@interface ViewController ()

/** AVPlayer */
@property (nonatomic,strong) HYVideoPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view addSubview:self.player];
}

- (HYVideoPlayer *)player{
    
    if (!_player) {
        
//        NSURL *url = [NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"];
        NSURL *url = [NSURL URLWithString:@"http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"];
        _player = [[HYVideoPlayer alloc] initWIthUrl:url];
        _player.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width / 2 + 40);
    }
    return _player;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
