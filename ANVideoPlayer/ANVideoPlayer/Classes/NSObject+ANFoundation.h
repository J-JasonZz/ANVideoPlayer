//
//  NSObject+ANFoundation.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ANFoundation)

void RUN_ON_UI_THREAD(dispatch_block_t block);

+ (NSString *)timeStringFromSecondsValue:(int)seconds;
@end
