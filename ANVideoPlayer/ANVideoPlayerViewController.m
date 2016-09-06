//
//  ANVideoPlayerViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANVideoPlayerViewController.h"

@interface ANVideoPlayerViewController ()<ANVideoPlayerDelegate>

@property (nonatomic, strong) NSURL *streamURL;

@end

@implementation ANVideoPlayerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.player = [[ANVideoPlayer alloc] init];
    self.player.delegate = self;
    [self.view addSubview:self.player.playerView];
    
    [self addConstraintForPlayerView];
}

- (void)addConstraintForPlayerView
{
    [self.player.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.player.playerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.player.playerView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.player.playerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.player.playerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)playVideoWithStreamURL:(NSURL*)streamURL
{
    self.streamURL = streamURL;
    [self.player loadVideoWithStreamURL:streamURL];
}

#pragma mark -- ANVideoPlayerDelegate
- (void)videoPlayer:(ANVideoPlayer *)videoPlayer closeButtonClick:(UIButton *)closeButton
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
