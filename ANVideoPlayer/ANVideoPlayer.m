//
//  ANVideoPlayer.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANVideoPlayer.h"
#import "ANVideoPlayerConfig.h"

#define degreesToRadians(x) (M_PI * x / 180.0f)

@interface ANVideoPlayer ()<ANVideoPlayerViewDelegate>

@property (nonatomic, strong) id timeObserver;

@end

@implementation ANVideoPlayer
{
    struct {
        unsigned int closeButtonClick : 1;
    } _delegateFlags;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ANVideoPlayer" owner:self options:nil];
        [self initialize];
        [self addObserver];
    }
    return self;
}

- (void)dealloc
{
    self.timeObserver = nil;
    self.player = nil;
    self.playerItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"status"];
    [self pauseContent:YES completionHandler:NULL];
}

- (void)initialize
{
    
    [self.playerView setDelegate:self];
    
    self.state = ANVideoPlayerStateUnknown;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.portraitFrame = CGRectMake(0, 0, MIN(bounds.size.width, bounds.size.height), MAX(bounds.size.width, bounds.size.height));
    self.landscapeFrame = CGRectMake(0, 0, MAX(bounds.size.width, bounds.size.height), MIN(bounds.size.width, bounds.size.height));
    
    self.supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)setDelegate:(id<ANVideoPlayerDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.closeButtonClick = self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:closeButtonClick:)];
}

- (void)addObserver
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(playerItemReadyToPlay) name:KANVideoPlayerItemReadyToPlay object:nil];
    [notificationCenter addObserver:self selector:@selector(playerStateChanged) name:KANVideoPlayerStateChange object:nil];
    [notificationCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)loadVideoWithStreamURL:(NSURL *)streamURL
{
    _steamURL = streamURL;
    self.state = ANVideoPlayerStateContentLoading;
    
    if (_steamURL == nil) {
        return;
    }
    
    VoidBlock completionHandler = ^{
        [self playVideo];
    };
    
    switch (self.state) {
        case ANVideoPlayerStateError:
        case ANVideoPlayerStateContentPaused:
        case ANVideoPlayerStateContentLoading:
            completionHandler();
            break;
        case ANVideoPlayerStateContentPlaying:
            break;
        default:
            break;
    };
}

- (void)playVideo
{
    [self clearPlayer];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.steamURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.playerView.playerLayerView setPlayer:self.player];
}

- (void)pauseContent:(BOOL)isUserAction completionHandler:(void (^)())completionHandler
{
    RUN_ON_UI_THREAD(^{
        
        switch ([self.playerItem status]) {
            case AVPlayerItemStatusFailed:
                self.state = ANVideoPlayerStateError;
                return;
                break;
            case AVPlayerItemStatusUnknown:
                self.state = ANVideoPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch ([self.player status]) {
            case AVPlayerStatusFailed:
                self.state = ANVideoPlayerStateError;
                return;
                break;
            case AVPlayerStatusUnknown:
                self.state = ANVideoPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch (self.state) {
            case ANVideoPlayerStateContentLoading:
            case ANVideoPlayerStateContentPlaying:
            case ANVideoPlayerStateContentPaused:
            case ANVideoPlayerStateSuspend:
            case ANVideoPlayerStateError:
                self.state = ANVideoPlayerStateContentPaused;
                if (completionHandler) completionHandler();
                break;
            default:
                break;
        }
    });
}

- (void)clearPlayer
{
    self.playerItem = nil;
    self.player = nil;
}

#pragma mark -- PlayerItem
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    [self removeOldPlayerItemObserver];
    _playerItem = playerItem;
    [self addNewPlayerItemObserver];
}

- (void)removeOldPlayerItemObserver
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)addNewPlayerItemObserver
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

#pragma mark -- Player
- (void)setPlayer:(AVPlayer *)player
{
    [self.player removeObserver:self forKeyPath:@"status"];
    self.timeObserver = nil;
    _player = player;
    if (player) {
        __weak __typeof(self) weakSelf = self;
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
            [weakSelf periodicTimeObserver:time];
        }];
    }
}
- (void)periodicTimeObserver:(CMTime)time {
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    
    if (timeInSeconds <= 0) {
        return;
    }
    
    if ([self.player currentItemDuration] > 1) {
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:timeInSeconds] forKey:@"scrubberValue"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kANVideoPlayerScrubberValueUpdatedNotification object:self userInfo:info];
  
        NSDictionary *durationInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:[self.player currentItemDuration]] forKey:@"duration"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kANVideoPlayerDurationDidLoadNotification object:self userInfo:durationInfo];
    }
}

- (void)setTimeObserver:(id)timeObserver {
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
    }
    _timeObserver = timeObserver;
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.playerItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                    if (self.player.status == AVPlayerStatusReadyToPlay) {
                        [notificationCenter postNotificationName:KANVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                    
                default:
                    break;
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
            NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:timeInterval] forKey:@"loadedTimeRanges"];
            [notificationCenter postNotificationName:KANVideoPlayerItemLoadedTimeRangesNotification object:nil userInfo:info];
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if (self.playerItem.playbackBufferEmpty) {
                self.state = ANVideoPlayerStateContentLoading;
            }
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.playerItem.playbackLikelyToKeepUp && self.state == ANVideoPlayerStateContentLoading) {
                [self playContent];
            }
        }
    }
    
    if (object == self.player) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.player.status) {
                case AVPlayerStatusReadyToPlay:
                    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                        [notificationCenter postNotificationName:KANVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                case AVPlayerStatusFailed:
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark -- Observer
- (void)playerItemReadyToPlay
{
    RUN_ON_UI_THREAD(^{
        switch (self.state) {
            case ANVideoPlayerStateContentPaused:
                break;
            case ANVideoPlayerStateContentLoading:{}
            case ANVideoPlayerStateError:{
                [self pauseContent:NO completionHandler:^{
                    [self seekToZeroDuration];
                }];
                break;
            }
            default:
                break;
        }
    });
}

- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    RUN_ON_UI_THREAD(^{
        [self pauseContent:NO completionHandler:NULL];
    });
}

- (void)playerStateChanged
{
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDevice * device = notification.object;
    
    UIInterfaceOrientation rotateToOrientation;
    switch(device.orientation) {
        case UIDeviceOrientationPortrait:
            rotateToOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotateToOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateToOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateToOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            break;
    }
    if ((1 << rotateToOrientation) & self.supportedOrientations && rotateToOrientation != self.visibleInterfaceOrientation) {
        [self performOrientationChange:rotateToOrientation];
    }
}

- (void)performOrientationChange:(UIInterfaceOrientation)deviceOrientation {
    
    CGFloat degrees = [self degreesForOrientation:deviceOrientation];
    __weak __typeof__(self) weakSelf = self;
    
    self.visibleInterfaceOrientation = deviceOrientation;
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGRect viewBoutnds;
        if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
            viewBoutnds = CGRectMake(0, 0, CGRectGetWidth(self.landscapeFrame), CGRectGetHeight(self.landscapeFrame));
        } else {
            viewBoutnds = CGRectMake(0, 0, CGRectGetWidth(self.portraitFrame), CGRectGetHeight(self.portraitFrame));
        }
        
        weakSelf.playerView.superview.transform = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        weakSelf.playerView.superview.bounds = viewBoutnds;
        [weakSelf.playerView.superview setFrameOriginX:0.0f];
        [weakSelf.playerView.superview setFrameOriginY:0.0f];
        
        CGRect wvFrame = weakSelf.playerView.superview.superview.frame;
        if (wvFrame.origin.y > 0) {
            wvFrame.size.height = CGRectGetHeight(bounds) ;
            wvFrame.origin.y = 0;
            weakSelf.playerView.superview.superview.frame = wvFrame;
        }
        
        weakSelf.playerView.bounds = viewBoutnds;
        [weakSelf.playerView setFrameOriginX:0.0f];
        [weakSelf.playerView setFrameOriginY:0.0f];
        
    } completion:^(BOOL finished) {
        
    }];
    
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: self.visibleInterfaceOrientation] forKey:@"orientation"];
    self.playerView.fullScreenButton.selected = self.isFullScreen = UIInterfaceOrientationIsLandscape(deviceOrientation);
}

- (CGFloat)degreesForOrientation:(UIInterfaceOrientation)deviceOrientation {
    switch (deviceOrientation) {
        case UIInterfaceOrientationPortrait:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 90;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return -90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 180;
            break;
        default:
            NSLog(@"%ld", deviceOrientation);
            break;
    }
    return 0;
}


#pragma mark - Playback position
- (void)seekToZeroDuration
{
    RUN_ON_UI_THREAD(^{
        [self.player seekToTimeInSeconds:0 completionHandler:^(BOOL finished) {
            if (finished) {
                [self playContent];
            }
        }];
    });
}

#pragma mark -- ControlEvents
- (void)playContent
{
    RUN_ON_UI_THREAD(^{
        // 开始播放时加载
        if (self.state == ANVideoPlayerStateContentPaused) {
            if (self.playerView.scrubber.value >= self.playerView.scrubber.maximumValue) {
                [self seekToZeroDuration];
            }
            self.state = ANVideoPlayerStateContentPlaying;
        }
        
        // 进度条拖动完成时加载
        if (self.state == ANVideoPlayerStateContentLoading) {
            if (self.playerView.scrubber.value >= self.playerView.scrubber.maximumValue) {
                [self seekToZeroDuration];
            }
            self.state = ANVideoPlayerStateContentPlaying;
        }
    });
}

#pragma mark -- PlayerState
- (void)setState:(ANVideoPlayerState)state
{
    switch (self.state) {
        case ANVideoPlayerStateUnknown:
            break;
        case ANVideoPlayerStateContentLoading:
            [self setLoading:NO];
            break;
        case ANVideoPlayerStateContentPlaying:
            break;
        case ANVideoPlayerStateContentPaused:
            self.playerView.bigPlayButton.hidden = YES;
            break;
        case ANVideoPlayerStateSuspend:
            break;
        case ANVideoPlayerStateDismissed:
            break;
        case ANVideoPlayerStateError:
            break;
        default:
            break;
    }
    
    _state = state;
    
    switch (self.state) {
        case ANVideoPlayerStateUnknown:
            break;
        case ANVideoPlayerStateContentLoading:
            [self setLoading:YES];
            self.playerView.playButton.enabled = NO;
            self.playerView.loadedTimeRangesProgress.hidden = YES;
            break;
        case ANVideoPlayerStateContentPlaying:
            self.playerView.playButton.selected = NO;
            self.playerView.bigPlayButton.selected = NO;
            self.playerView.playButton.enabled = YES;
            self.playerView.loadedTimeRangesProgress.hidden = NO;
            [self.player play];
            break;
        case ANVideoPlayerStateContentPaused:
            self.playerView.playButton.selected = YES;
            self.playerView.bigPlayButton.selected = YES;
            self.playerView.bigPlayButton.hidden = NO;
            [self.player pause];
            break;
        case ANVideoPlayerStateSuspend:
            break;
        case ANVideoPlayerStateDismissed:
            break;
        case ANVideoPlayerStateError:
            [self.player pause];
            break;
        default:
            break;
    }
}

- (void)setLoading:(BOOL)loading {
    if (loading) {
        [self.playerView.activityIndicator startAnimating];
    } else {
        [self.playerView.activityIndicator stopAnimating];
    }
}

#pragma mark - AVPlayer wrappers

- (BOOL)isPlayingVideo {
    return (self.player && self.player.rate != 0.0);
}

/**
 *  返回 当前 视频 缓存时长
 */
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
}

#pragma mark -- ANVideoPlayerViewDelegate
- (void)closeButtonTapped
{
    if (self.isFullScreen) {
        [self performOrientationChange:UIInterfaceOrientationPortrait];
    }
    if (_delegateFlags.closeButtonClick) {
        [self.delegate videoPlayer:self closeButtonClick:self.playerView.closeButton];
    }
}

- (void)fullScreenButtonTapped
{
    self.isFullScreen = self.playerView.fullScreenButton.selected;
    
    if (self.isFullScreen) {
        [self performOrientationChange:UIInterfaceOrientationLandscapeRight];
    } else {
        [self performOrientationChange:UIInterfaceOrientationPortrait];
    }
}

- (void)bigPlayButtonTapped
{
    if (!self.playerView.bigPlayButton.selected) {
        [self playContent];
    } else {
        switch (self.state) {
            case ANVideoPlayerStateContentPlaying:
                [self pauseContent:YES completionHandler:nil];
                break;
            default:
                break;
        }
    }
}

- (void)playButtonTapped
{
    if (!self.playerView.playButton.selected) {
        [self playContent];
    } else {
        switch (self.state) {
            case ANVideoPlayerStateContentPlaying:
                [self pauseContent:YES completionHandler:nil];
                break;
            default:
                break;
        }
    }
}

- (void)playViewTapped
{
    
}

- (void)scrubberBegin
{
    [self pauseContent:YES completionHandler:NULL];
}

- (void)scrubberEnd
{
    self.state = ANVideoPlayerStateContentLoading;
    [self.player seekToTimeInSeconds:self.playerView.scrubber.value completionHandler:^(BOOL finished) {
        if (finished) [self playContent];
    }];
}

@end


#pragma mark -- AVPlayerCategory
@implementation AVPlayer (VKPlayer)

- (void)seekToTimeInSeconds:(float)time completionHandler:(void (^)(BOOL finished))completionHandler {
    if ([self respondsToSelector:@selector(seekToTime:toleranceBefore:toleranceAfter:completionHandler:)]) {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
    } else {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        completionHandler(YES);
    }
}

- (NSTimeInterval)currentItemDuration {
    return CMTimeGetSeconds([self.currentItem duration]);
}

- (CMTime)currentCMTime {
    return [self currentTime];
}

@end