//
//  ANVideoPlayerView.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANVideoPlayerView.h"
#import "ANVideoPlayerConfig.h"

#define KControlsHideInterval 5.f

@implementation ANVideoPlayerView
{
    struct {
        unsigned int closeButtonTapped : 1;
        unsigned int fullScreenButtonTapped : 1;
        unsigned int bigPlayButtonTapped : 1;
        unsigned int playButtonTapped : 1;
        unsigned int playViewTapped : 1;
        unsigned int scrubberBegin : 1;
        unsigned int scrubberEnd : 1;
    } _delegateFlags;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
        [self addObserver];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopControlsTimer];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
    [self addObserver];
}

- (void)initialize
{    
    // 播放进度条
    [self.scrubber setThumbImage:[UIImage imageNamed:@"ANScrubber_thumb"] forState:UIControlStateNormal];
    [self.scrubber setMaximumTrackTintColor:[UIColor grayColor]];
    [self.scrubber setMinimumTrackTintColor:kUIColorFromRGB(0x00F5FF)];
    
    // 缓冲进度条
    self.loadedTimeRangesProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    self.loadedTimeRangesProgress.trackTintColor    = [UIColor clearColor];
    self.loadedTimeRangesProgress.userInteractionEnabled = NO;
    
    // 顶部控制视图阴影
    UIView *topOverlay = [[UIView alloc] initWithFrame:self.topControlOverlay.frame];
    topOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    topOverlay.backgroundColor = [UIColor blackColor];
    topOverlay.alpha = 0.6f;
    [self.topControlOverlay addSubview:topOverlay];
    [self.topControlOverlay sendSubviewToBack:topOverlay];
    
    // 底部控制视图阴影
    UIView* bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomControlOverlay.frame.size.width, self.bottomControlOverlay.frame.size.height)];
    bottomOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    bottomOverlay.backgroundColor = [UIColor blackColor];
    bottomOverlay.alpha = 0.6f;
    [self.bottomControlOverlay addSubview:bottomOverlay];
    [self.bottomControlOverlay sendSubviewToBack:bottomOverlay];
    
    // 视图点击手势
    UITapGestureRecognizer *playerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewTapHandle:)];
    [self addGestureRecognizer:playerViewTap];
    
    // 播放进度条拖动
    [self.scrubber addTarget:self action:@selector(scrubberDragBegin) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDragEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.scrubber addTarget:self action:@selector(scrubberValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self startControlsTimer];
    self.isControlsHidden = NO;
}

- (void)addObserver
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(durationDidLoad:) name:kANVideoPlayerDurationDidLoadNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(scrubberValueUpdated:) name:kANVideoPlayerScrubberValueUpdatedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(loadedTimeRangesUpdate:) name:KANVideoPlayerItemLoadedTimeRangesNotification object:nil];
}

- (void)setDelegate:(id<ANVideoPlayerViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.closeButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(closeButtonTapped)];
    _delegateFlags.fullScreenButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(fullScreenButtonTapped)];
    _delegateFlags.bigPlayButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(bigPlayButtonTapped)];
    _delegateFlags.playButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(playButtonTapped)];
    _delegateFlags.scrubberBegin = self.delegate && [self.delegate respondsToSelector:@selector(scrubberBegin)];
    _delegateFlags.scrubberEnd = self.delegate && [self.delegate respondsToSelector:@selector(scrubberEnd)];
}

#pragma mark -- Observer
- (void)durationDidLoad:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSNumber* duration = [info objectForKey:@"duration"];
    
    RUN_ON_UI_THREAD(^{
        self.scrubber.maximumValue = [duration floatValue];
    });
}

- (void)scrubberValueUpdated:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    RUN_ON_UI_THREAD(^{
        [self.scrubber setValue:[[info objectForKey:@"scrubberValue"] floatValue] animated:YES];
        [self updateTimeLabel];
    });
}

- (void)loadedTimeRangesUpdate:(NSNotification *)notification
{
    if (self.scrubber.maximumValue <= 1.0) {
        return;
    }
    
    NSDictionary *info = [notification userInfo];
    RUN_ON_UI_THREAD(^{
        self.loadedTimeRangesProgress.progress = [info[@"loadedTimeRanges"] floatValue] / self.scrubber.maximumValue;
    });
}

#pragma mark -- ControlsTimer
- (void)startControlsTimer
{
    [self stopControlsTimer];
    self.controlsTimer = [NSTimer scheduledTimerWithTimeInterval:KControlsHideInterval target:self selector:@selector(controlsTimerHandle) userInfo:nil repeats:NO];
}

- (void)stopControlsTimer
{
    if (self.controlsTimer.isValid) {
        [self.controlsTimer invalidate];
        self.controlsTimer = nil;
    }
}

- (void)controlsTimerHandle
{
    if (!self.isControlsHidden) {
        self.controlView.hidden = YES;
        self.isControlsHidden = YES;
    }
}

#pragma mark -- updateView
- (void)updateTimeLabel
{
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [NSObject timeStringFromSecondsValue:(int)self.scrubber.value], [NSObject timeStringFromSecondsValue:(int)self.scrubber.maximumValue]];
}

#pragma mark -- Events
- (void)playerViewTapHandle:(UITapGestureRecognizer *)playerViewTap
{
    self.controlView.hidden = !self.isControlsHidden;
    self.isControlsHidden ? [self startControlsTimer] : [self stopControlsTimer];
    self.isControlsHidden = !self.isControlsHidden;
}

- (IBAction)closeButtonClick:(id)sender {
    if (_delegateFlags.closeButtonTapped) {
        [self stopControlsTimer];
        [self.delegate closeButtonTapped];
    }
}

- (IBAction)playButtonClick:(id)sender {
    self.playButton.selected = !self.playButton.selected;
    self.playButton.selected ? [self stopControlsTimer] : [self startControlsTimer];
    if (_delegateFlags.playButtonTapped) {
        [self.delegate playButtonTapped];
    }
}

- (IBAction)bigPlayButtonClick:(id)sender {
    self.bigPlayButton.selected = !self.bigPlayButton.selected;
    self.bigPlayButton.selected ? [self stopControlsTimer] : [self startControlsTimer];
    if (_delegateFlags.bigPlayButtonTapped) {
        [self.delegate bigPlayButtonTapped];
    }
}

- (IBAction)fullScreenButtonClick:(id)sender {
    self.fullScreenButton.selected = !self.fullScreenButton.selected;
    [self startControlsTimer];
    if (_delegateFlags.fullScreenButtonTapped) {
        [self.delegate fullScreenButtonTapped];
    }
}

- (void)scrubberDragBegin
{
    [self stopControlsTimer];
    if (_delegateFlags.scrubberBegin) {
        [self.delegate scrubberBegin];
    }
}

- (void)scrubberDragEnd
{
    [self startControlsTimer];
    if (_delegateFlags.scrubberEnd) {
        [self.delegate scrubberEnd];
    }
}

- (void)scrubberValueChanged
{
    [self updateTimeLabel];
}

@end
