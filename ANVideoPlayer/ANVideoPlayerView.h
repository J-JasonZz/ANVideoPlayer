//
//  ANVideoPlayerView.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANVideoPlayerLayerView.h"

typedef NS_ENUM(NSInteger, ANVideoPlayerViewState){
    ANVideoPlayerViewStatePortrait, // 竖屏播放
    ANVideoPlayerViewStateLandscape, // 横屏播放
    ANVideoPlayerViewStateWindow // 小窗播放
};

@protocol ANVideoPlayerViewDelegate <NSObject>

- (void)closeButtonTapped;

- (void)windowCloseButtonTapped;

- (void)fullScreenButtonTapped;

- (void)bigPlayButtonTapped;

- (void)playButtonTapped;

- (void)playViewTapped;

- (void)scrubberBegin;

- (void)scrubberEnd;

@end

@interface ANVideoPlayerView : UIView

@property (nonatomic, weak) id<ANVideoPlayerViewDelegate> delegate;

// 播放器展示状态
@property (nonatomic, assign) ANVideoPlayerViewState state;
// 是否是直播
@property (nonatomic, assign) BOOL isLive;

// 播放器单击手势
@property (nonatomic, strong) UITapGestureRecognizer *playerViewTap;
// 播放器拖动手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

// 播放视图
@property (weak, nonatomic) IBOutlet ANVideoPlayerLayerView *playerLayerView;

// 控制视图
@property (weak, nonatomic) IBOutlet UIView *controlView;
// 顶部控制层
@property (weak, nonatomic) IBOutlet UIView *topControlOverlay;
// 关闭播放按钮
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *windowButton;
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
// 直播间隔view
@property (weak, nonatomic) IBOutlet UIView *onLiveSpaceView;
// 直播中按钮
@property (weak, nonatomic) IBOutlet UIButton *onLiveButton;

// 大播放按钮
@property (weak, nonatomic) IBOutlet UIButton *bigPlayButton;
// 菊花
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
// 窗口播放模式关闭
@property (weak, nonatomic) IBOutlet UIButton *windowCloseButton;

// 控制视图显示
@property (nonatomic, assign) BOOL isControlsHidden;

// 控制视图隐藏定时器
@property (nonatomic, strong) NSTimer *controlsTimer;

@end
