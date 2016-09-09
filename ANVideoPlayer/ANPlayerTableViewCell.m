//
//  ANPlayerTableViewCell.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/9.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANPlayerTableViewCell.h"
#import <UIImageView+WebCache.h>

@implementation ANPlayerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)assginValueWithPlayerModel:(ANPlayerModel *)model
{
    _playerTitle.text = model.title;
    [_playerImageView sd_setImageWithURL:[NSURL URLWithString:model.coverImageUrl]];
}

- (IBAction)playAction:(id)sender {
    if (self.playButtonClick) {
        self.playButtonClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
