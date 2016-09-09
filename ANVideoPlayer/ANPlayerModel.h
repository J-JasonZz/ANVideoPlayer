//
//  ANPlayerModel.h
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/9.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPlayerModel : NSObject
// 视频url
@property (nonatomic, copy) NSString *playUrl;
// 视频占位图
@property (nonatomic, copy) NSString *coverImageUrl;
// 视频标题
@property (nonatomic, copy) NSString *title;

@end
