//
//  ViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ViewController.h"
#import "ANVideoPlayerUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)presentAction:(id)sender {
    [[ANVideoPlayerUtil shareUtil] playVideoWithStreamURL:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14559682994064.mp4"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
