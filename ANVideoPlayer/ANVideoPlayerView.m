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

#define KWindowDisplayWidth 170.f
#define KWindowDisplayHeight 170.f / (16.f / 9.f)

@interface ANVideoPlayerView ()

@property (nonatomic, assign) BOOL isSwiping;

@end

@implementation ANVideoPlayerView
{
    struct {
        unsigned int closeButtonTapped : 1;
        unsigned int windowCloseButtonTapped : 1;
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
    NSLog(@"%@", self.class);
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
    self.playerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewTapHandle:)];
    [self addGestureRecognizer:self.playerViewTap];
    
    // 视图右拖动手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    [self addGestureRecognizer:self.panGesture];
    
    // 播放进度条拖动
    [self.scrubber addTarget:self action:@selector(scrubberDragBegin) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDragEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.scrubber addTarget:self action:@selector(scrubberValueChanged) forControlEvents:UIControlEventValueChanged];
        
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
    _delegateFlags.windowCloseButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(windowCloseButtonTapped)];
    _delegateFlags.fullScreenButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(fullScreenButtonTapped)];
    _delegateFlags.bigPlayButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(bigPlayButtonTapped)];
    _delegateFlags.playButtonTapped = self.delegate && [self.delegate respondsToSelector:@selector(playButtonTapped)];
    _delegateFlags.scrubberBegin = self.delegate && [self.delegate respondsToSelector:@selector(scrubberBegin)];
    _delegateFlags.scrubberEnd = self.delegate && [self.delegate respondsToSelector:@selector(scrubberEnd)];
}

- (void)setState:(ANVideoPlayerViewState)state
{
    ANVideoPlayerViewState oldState = _state;
    _state = state;
    switch (self.state) {
        case ANVideoPlayerViewStatePortrait:
            self.windowCloseButton.hidden = YES;
            if (oldState == ANVideoPlayerViewStateWindow) {
                self.controlView.hidden = NO;
                self.isControlsHidden = NO;
            }
            self.windowButton.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self startControlsTimer];
            break;
        case ANVideoPlayerViewStateLandscape:
            self.windowButton.hidden = YES;
            break;
        case ANVideoPlayerViewStateWindow:
            self.windowCloseButton.hidden = NO;
            self.controlView.hidden = YES;
            self.isControlsHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self stopControlsTimer];
            break;
        default:
            break;
    }
}

- (void)setIsLive:(BOOL)isLive
{
    _isLive = isLive;
    _isLive ? [self setPlayerViewOnLive] : [self setPlayerViewsOnDemand];
}
// 点播
- (void)setPlayerViewsOnDemand
{
    self.onLiveSpaceView.hidden = YES;
    self.onLiveButton.hidden = YES;
}
// 直播
- (void)setPlayerViewOnLive
{
    self.scrubber.hidden = YES;
    self.loadedTimeRangesProgress.hidden = YES;
    self.timeLabel.hidden = YES;
}

#pragma mark -- Observer
- (void)durationDidLoad:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSNumber* duration = [info objectForKey:@"duration"];
    
    if (!([duration floatValue] > 0)) {
        return;
    }
    
    RUN_ON_UI_THREAD(^{
        self.scrubber.maximumValue = [duration floatValue];
    });
}

- (void)scrubberValueUpdated:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    if ([[info objectForKey:@"scrubberValue"] floatValue] <= 0) {
        return;
    }
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
    if (self.state == ANVideoPlayerViewStateWindow) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = KScreenBounds;
        }completion:^(BOOL finished) {
            self.state = ANVideoPlayerViewStatePortrait;
        }];
    } else {
        self.controlView.hidden = !self.isControlsHidden;
        self.isControlsHidden ? [self startControlsTimer] : [self stopControlsTimer];
        self.isControlsHidden = !self.isControlsHidden;
    }
}

- (void)swipePanGestureHandler:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:self];

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (self.state == ANVideoPlayerViewStatePortrait || self.state == ANVideoPlayerViewStateWindow) [self startPanPlayerView];
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        if (self.state == ANVideoPlayerViewStatePortrait) [self endPanPlayerViewWhenPortrait];
        if (self.state == ANVideoPlayerViewStateWindow) [self endPanPlayerViewWhenWindow];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        if (self.state == ANVideoPlayerViewStatePortrait) [self panPlayerViewWhenPortraitWithPanGestureDistance:translation.x];
        if (self.state == ANVideoPlayerViewStateWindow) [self panPlayerViewWhenWindowWithPanGestureTranslation:translation];
    }
}

- (IBAction)closeButtonClick:(id)sender {
    if (_delegateFlags.closeButtonTapped) {
        [self stopControlsTimer];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.delegate closeButtonTapped];
    }
}

- (IBAction)windowButtonClick:(id)sender {
    self.isSwiping = YES;
    self.state = ANVideoPlayerViewStateWindow;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(KScreenBounds.size.width - 15.f - KWindowDisplayWidth, KScreenBounds.size.height - KWindowDisplayHeight - 45.f, KWindowDisplayWidth, KWindowDisplayHeight);
    }completion:^(BOOL finished) {
        self.isSwiping = NO;
    }];
}
- (IBAction)windowCloseButtonClick:(id)sender {
    if (_delegateFlags.windowCloseButtonTapped) {
        [self stopControlsTimer];
        [self.delegate windowCloseButtonTapped];
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

#pragma mark -- PanPlayerViewHandler
- (void)startPanPlayerView
{
    if (self.isSwiping) {
        return;
    }
    
    if (self.state == ANVideoPlayerViewStatePortrait) [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.isSwiping = YES;
}

- (void)panPlayerViewWhenPortraitWithPanGestureDistance:(CGFloat)distance
{
    if (distance <= 0) return;
    if (!self.isSwiping) return;
    
    CGFloat rate = distance / (KScreenBounds.size.width*2);
    
    CGFloat widthPaddign = 15.f;
    CGFloat heightPadding = 45.f;
    
    [self setFrameOriginX:(KScreenBounds.size.width - widthPaddign - KWindowDisplayWidth) * rate];
    [self setFrameOriginY:(KScreenBounds.size.height - heightPadding - KWindowDisplayHeight) * rate];
    
    [self setFrameWidth:KScreenBounds.size.width - self.frame.origin.x - (widthPaddign * rate)];
    [self setFrameHeight:KScreenBounds.size.height - self.frame.origin.y - (heightPadding * rate)];
}

- (void)endPanPlayerViewWhenPortrait
{
    if (!self.isSwiping) return;

    if (self.frame.origin.x >= 50.f) {
        self.state = ANVideoPlayerViewStateWindow;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(KScreenBounds.size.width - 15.f - KWindowDisplayWidth, KScreenBounds.size.height - KWindowDisplayHeight - 45.f, KWindowDisplayWidth, KWindowDisplayHeight);
        }completion:^(BOOL finished) {
            self.isSwiping = NO;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = KScreenBounds;
        }completion:^(BOOL finished) {
            self.isSwiping = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
    }
}

- (void)panPlayerViewWhenWindowWithPanGestureTranslation:(CGPoint)translation
{
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [self.panGesture setTranslation:CGPointZero inView:[UIApplication sharedApplication].delegate.window];
}

- (void)endPanPlayerViewWhenWindow
{
    if (self.center.x <= KScreenBounds.size.width / 2.f) {
        [UIView animateWithDuration:0.3f animations:^{
            CGPoint center = self.center;
            center.x = 15.f + KWindowDisplayWidth / 2.f;
            if (self.center.y < 15.f + KWindowDisplayHeight / 2.f) {
                center.y = 15.f + KWindowDisplayHeight / 2.f;
            } else if (self.center.y > KScreenBounds.size.height - 15.f - KWindowDisplayHeight / 2.f) {
                center.y = KScreenBounds.size.height - 15.f - KWindowDisplayHeight / 2.f;
            }
            self.center = center;
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            CGPoint center = self.center;
            center.x = KScreenBounds.size.width - 15.f - KWindowDisplayWidth / 2.f;
            if (self.center.y < 15.f + KWindowDisplayHeight / 2.f) {
                center.y = 15.f + KWindowDisplayHeight / 2.f;
            } else if (self.center.y > KScreenBounds.size.height - 15.f - KWindowDisplayHeight / 2.f) {
                center.y = KScreenBounds.size.height - 15.f - KWindowDisplayHeight / 2.f;
            }
            self.center = center;
        }];
    }
}


@end
