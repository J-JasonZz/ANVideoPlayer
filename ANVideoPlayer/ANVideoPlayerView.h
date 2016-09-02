//
//  ANVideoPlayerView.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANVideoPlayerLayerView.h"

@protocol ANVideoPlayerViewDelegate <NSObject>

- (void)closeButtonTapped;

- (void)fullScreenButtonTapped;

- (void)bigPlayButtonTapped;

- (void)playButtonTapped;

- (void)playViewTapped;

- (void)scrubberBegin;

- (void)scrubberEnd;

@end

@interface ANVideoPlayerView : UIView

@property (nonatomic, weak) id<ANVideoPlayerViewDelegate> delegate;

// 播放视图
@property (weak, nonatomic) IBOutlet ANVideoPlayerLayerView *playerLayerView;

// 控制视图
@property (weak, nonatomic) IBOutlet UIView *controlView;
// 顶部控制层
@property (weak, nonatomic) IBOutlet UIView *topControlOverlay;
// 关闭播放按钮
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
// 底部控制层
@property (weak, nonatomic) IBOutlet UIView *bottomControlOverlay;
// 播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
// 播放进度条
@property (weak, nonatomic) IBOutlet UISlider *scrubber;
// 缓冲进度条
@property (weak, nonatomic) IBOutlet UIProgressView *loadedTimeRangesProgress;
// 当前时间/总时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
// 全屏按钮
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;

// 大播放按钮
@property (weak, nonatomic) IBOutlet UIButton *bigPlayButton;
// 菊花
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// 控制视图显示
@property (nonatomic, assign) BOOL isControlsHidden;

@end
