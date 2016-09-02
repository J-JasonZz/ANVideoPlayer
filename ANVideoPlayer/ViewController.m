//
//  ViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ViewController.h"
#import "ANVideoPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)presentAction:(id)sender {
    ANVideoPlayerViewController *controller = [[ANVideoPlayerViewController alloc] init];
    [self presentViewController:controller animated:YES completion:NULL];
    
    [controller playVideoWithStreamURL:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14559682994064.mp4"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
