//
//  ANPlayerTableViewCell.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/9.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANPlayerModel.h"

typedef void(^PlayButtonClick)(void);

@interface ANPlayerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playerTitle;

@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;

@property (nonatomic, copy) PlayButtonClick playButtonClick;

- (void)assginValueWithPlayerModel:(ANPlayerModel *)model;
@end
