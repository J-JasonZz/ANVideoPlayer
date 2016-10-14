//
//  ANVideoPlayerUtil.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/8.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANVideoPlayerUtil.h"

@interface ANVideoPlayerUtil ()<ANVideoPlayerDelegate>

@property (nonatomic, strong) ANVideoPlayer *currentPlayer;

@end

@implementation ANVideoPlayerUtil

+ (instancetype)shareUtil
{
    static ANVideoPlayerUtil *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[ANVideoPlayerUtil alloc] init];
    });
    return util;
}

- (void)playVideoWithStreamURL:(NSURL *)streamURL isLive:(BOOL)isLive
{
    NSLog(@"play");
    [self.currentPlayer.playerView removeFromSuperview];
    self.currentPlayer = nil;
    
    self.currentPlayer = [[ANVideoPlayer alloc] init];
    self.currentPlayer.playerView.frame = [UIScreen mainScreen].bounds;
    self.currentPlayer.delegate = self;
    self.currentPlayer.isLive = isLive;
    self.currentPlayer.playerView.alpha = 0.0;
    [[UIApplication sharedApplication].delegate.window addSubview:self.currentPlayer.playerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currentPlayer.playerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.currentPlayer loadVideoWithStreamURL:streamURL];
    }];
}

- (void)dismissCurrentPlayer
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentPlayer.playerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.currentPlayer.playerView removeFromSuperview];
        self.currentPlayer = nil;
    }];
}

#pragma mark -- ANVideoPlayerDelegate
- (void)videoPlayer:(ANVideoPlayer *)videoPlayer closeButtonClick:(UIButton *)closeButton
{
    [self dismissCurrentPlayer];
}



@end
