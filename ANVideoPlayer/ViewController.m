//
//  ViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/8/31.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ViewController.h"
#import "ANPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pushAction:(id)sender {
    ANPlayerViewController *controller = [[ANPlayerViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
