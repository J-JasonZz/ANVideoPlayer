//
//  ANVideoPlayerViewController.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANVideoPlayer.h"

@interface ANVideoPlayerViewController : UIViewController

@property (nonatomic, strong) ANVideoPlayer *player;

- (void)playVideoWithStreamURL:(NSURL*)streamURL;
@end
