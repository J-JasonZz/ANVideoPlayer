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

typedef void (^VoidBlock)();

#define KScreenBounds [[UIScreen mainScreen] bounds]
//十六进制色值
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define KANVideoPlayerItemReadyToPlay @"ANVideoPlayerItemReadyToPlay"
#define KANVideoPlayerItemStatusFailed @"ANVideoPlayerItemStatusFailed"

#define kANVideoPlayerDurationDidLoadNotification @"ANVideoPlayerDurationDidLoadNotification"
#define kANVideoPlayerScrubberValueUpdatedNotification @"ANVideoPlayerScrubberValueUpdatedNotification"
#define KANVideoPlayerItemLoadedTimeRangesNotification @"ANVideoPlayerItemLoadedTimeRangesNotification"

#endif /* ANVideoPlayerConfig_h */
