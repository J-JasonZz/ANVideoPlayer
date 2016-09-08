//
//  ViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ViewController.h"
#import "ANVideoPlayer.h"

@interface ViewController ()<ANVideoPlayerDelegate>

@property (nonatomic, strong) ANVideoPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (IBAction)presentAction:(id)sender {
    self.player = [[ANVideoPlayer alloc] init];
    self.player.playerView.frame = [UIScreen mainScreen].bounds;
    self.player.delegate = self;
    self.player.playerView.alpha = 0.0;
    [[UIApplication sharedApplication].delegate.window addSubview:self.player.playerView];
    [UIView animateWithDuration:0.3 animations:^{
        self.player.playerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.player loadVideoWithStreamURL:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14559682994064.mp4"]];
    }];
}

#pragma mark -- ANVideoPlayerDelegate
- (void)videoPlayer:(ANVideoPlayer *)videoPlayer closeButtonClick:(UIButton *)closeButton
{
    [UIView animateWithDuration:0.3 animations:^{
        self.player.playerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.player.playerView.hidden = YES;
        self.player = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
