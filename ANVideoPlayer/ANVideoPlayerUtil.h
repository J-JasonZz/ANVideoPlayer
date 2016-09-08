//
//  ANVideoPlayerUtil.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/8.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANVideoPlayer.h"

@interface ANVideoPlayerUtil : NSObject

@property (nonatomic, strong, readonly) ANVideoPlayer *currentPlayer;

+ (instancetype)shareUtil;

- (void)playVideoWithStreamURL:(NSURL *)streamURL;

- (void)dismissCurrentPlayer;
@end
