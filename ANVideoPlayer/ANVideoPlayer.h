//
//  ANVideoPlayer.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANVideoPlayerView.h"

typedef NS_ENUM(NSInteger, ANVideoPlayerState){
    ANVideoPlayerStateUnknown,
    ANVideoPlayerStateContentLoading,
    ANVideoPlayerStateContentPlaying,
    ANVideoPlayerStateContentPaused,
    ANVideoPlayerStateSuspend,
    ANVideoPlayerStateDismissed,
    ANVideoPlayerStateError
};

@class ANVideoPlayer;
@protocol ANVideoPlayerDelegate <NSObject>
// 关闭按钮点击
- (void)videoPlayer:(ANVideoPlayer *)videoPlayer closeButtonClick:(UIButton *)closeButton;

@end

@interface ANVideoPlayer : NSObject

@property (strong, nonatomic) IBOutlet ANVideoPlayerView *playerView;

@property (nonatomic, weak) id<ANVideoPlayerDelegate> delegate;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, assign) ANVideoPlayerState state;

@property (nonatomic, strong, readonly) NSURL *steamURL;

@property (nonatomic, assign) CGRect portraitFrame;

@property (nonatomic, assign) CGRect landscapeFrame;

@property (nonatomic, assign) UIInterfaceOrientation visibleInterfaceOrientation;

@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@property (nonatomic, assign) BOOL isFullScreen;
// 是否是直播
@property (nonatomic, assign) BOOL isLive;

- (void)loadVideoWithStreamURL:(NSURL*)streamURL;
@end


@interface AVPlayer (ANPlayer)

- (void)seekToTimeInSeconds:(float)time completionHandler:(void (^)(BOOL finished))completionHandler;
- (NSTimeInterval)currentItemDuration;
- (CMTime)currentCMTime;

@end
