//
//  UIView+ANFoundation.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/1.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "UIView+ANFoundation.h"

@implementation UIView (ANFoundation)
- (void)setFrameWidth:(CGFloat)newWidth {
    CGRect f = self.frame;
    f.size.width = newWidth;
    self.frame = f;
}

- (void)setFrameHeight:(CGFloat)newHeight {
    CGRect f = self.frame;
    f.size.height = newHeight;
    self.frame = f;
}

- (void)setFrameOriginX:(CGFloat)newX {
    CGRect f = self.frame;
    f.origin.x = newX;
    self.frame = f;
}

- (void)setFrameOriginY:(CGFloat)newY {
    CGRect f = self.frame;
    f.origin.y = newY;
    self.frame = f;
}
@end
