//
//  ANVideoPlayerConfig.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#ifndef ANVideoPlayerConfig_h
#define ANVideoPlayerConfig_h

#import <AVFoundation/AVFoundation.h>
#import "NSObject+ANFoundation.h"
#import "UIView+ANFoundation.h"
#import "MainConfig.h"

typedef void (^VoidBlock)();

#define KANVideoPlayerItemReadyToPlay @"ANVideoPlayerItemReadyToPlay"
#define KANVideoPlayerStateChange @"ANVideoPlayerStateChange"

#define kANVideoPlayerDurationDidLoadNotification @"ANVideoPlayerDurationDidLoadNotification"
#define kANVideoPlayerScrubberValueUpdatedNotification @"ANVideoPlayerScrubberValueUpdatedNotification"
#define KANVideoPlayerItemLoadedTimeRangesNotification @"ANVideoPlayerItemLoadedTimeRangesNotification"

#endif /* ANVideoPlayerConfig_h */
