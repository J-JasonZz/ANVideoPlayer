//
//  NSObject+ANFoundation.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "NSObject+ANFoundation.h"

@implementation NSObject (ANFoundation)

void RUN_ON_UI_THREAD(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (NSString *)timeStringFromSecondsValue:(int)seconds
{
    NSString *retVal;
    int hours = seconds / 3600;
    int minutes = (seconds / 60) % 60;
    int secs = seconds % 60;
    if (hours > 0) {
        retVal = [NSString stringWithFormat:@"%01d:%02d:%02d", hours, minutes, secs];
    } else {
        retVal = [NSString stringWithFormat:@"%02d:%02d", minutes, secs];
    }
    return retVal;
}

@end
