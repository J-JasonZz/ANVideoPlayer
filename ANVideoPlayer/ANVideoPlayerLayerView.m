//
//  ANVideoPlayerLayerView.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANVideoPlayerLayerView.h"

@implementation ANVideoPlayerLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
