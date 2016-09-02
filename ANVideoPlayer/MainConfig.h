//
//  MainConfig.h
//  baoer
//
//  Created by 杨向辉 on 16/3/18.
//  Copyright © 2016年 yangxh. All rights reserved.
//

#ifndef MainConfig_h
#define MainConfig_h

#define kReleaseUrl @"https://bao.wallstreetcn.com"
#define kDebugUrl @"http://test.xgb.io:3000"

#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kNavigationHeight 64.f
#define kBottomSheetHeight 49.f
#define kCommandMargin 15.f
#define kStatusHeight 20.f

#pragma mark - Colors
//十六进制色值
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kUIColorFromRGBWithTransparent(rgbValue,transparentValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:transparentValue]

//RGB色值
#define kColorWithRGB(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define kColorWithRGBAndAlpha(r,g,b,a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a];
//透明色值
#define kCLEARCOLOR [UIColor clearColor]

#pragma mark - String  functions
//空字符串
#define kEMPTY_STRING        @""
//
#define kSTR(key)            NSLocalizedString(key, nil)

#pragma mark - UIImage  UIImageView  functions
#define kIMG(name) [UIImage imageNamed:name]

#pragma mark - File  functions
#define kPATH_OF_APP_HOME    NSHomeDirectory()
#define kPATH_OF_TEMP        NSTemporaryDirectory()
#define kPATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kIOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//打印
#pragma mark - log  flag
#define LogFrame(frame) NSLog(@"frame[X=%.1f,Y=%.1f,W=%.1f,H=%.1f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height)
#define LogPoint(point) NSLog(@"Point[X=%.1f,Y=%.1f]",point.x,point.y)

#pragma mark - Size ,X,Y, View ,Frame
//get the  size of the Screen
#define kSCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define kSCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define kHEIGHT_SCALE  ([[UIScreen mainScreen]bounds].size.height/480.0)
#define kSCREEN [[UIScreen mainScreen]bounds]
#define kVIEW_HEIGHT  self.view.bounds.size.height
#define kVIEW_WIDTH  self.view.bounds.size.width

//适配各种屏幕 设计稿按ios5的屏幕来适配
#define kFitHeight_subs(oHeight) oHeight* ((kSCREEN_HEIGHT/568 -1) / 3 + 1 )
#define kFitHeight(oHeight) oHeight*kSCREEN_HEIGHT/568
#define kFitWidth(oWidth) oWidth*kSCREEN_WIDTH/320

//get the  size of the Application
#define kAPP_HEIGHT [[UIScreen mainScreen]applicationFrame].size.height
#define kAPP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width

#define kAPP_SCALE_H  ([[UIScreen mainScreen]applicationFrame].size.height/480.0)
#define kAPP_SCALE_W  ([[UIScreen mainScreen]applicationFrame].size.width/320.0)

//get the left top origin's x,y of a view
#define kVIEW_TX(view) (view.frame.origin.x)
#define kVIEW_TY(view) (view.frame.origin.y)

//get the width size of the view:width,height
#define kVIEW_W(view)  (view.frame.size.width)
#define kVIEW_H(view)  (view.frame.size.height)

//get the right bottom origin's x,y of a view
#define kVIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
#define kVIEW_BY(view) (view.frame.origin.y + view.frame.size.height )

//get the x,y of the frame
#define kFRAME_TX(frame)  (frame.origin.x)
#define kFRAME_TY(frame)  (frame.origin.y)
//get the size of the frame
#define kFRAME_W(frame)  (frame.size.width)
#define kFRAME_H(frame)  (frame.size.height)

#define kVIEW_W1(view)  (view.bounds.size.width)
#define kVIEW_H1(view)  (view.bounds.size.height)

#define kDistanceFloat(PointA,PointB) sqrtf((PointA.x - PointB.x) * (PointA.x - PointB.x) + (PointA.y - PointB.y) * (PointA.y - PointB.y))

//iphone6Plus判断
#define kDEVICE_IS_IPHONE6Plus ([[UIScreen mainScreen] bounds].size.height == 736)

//iphone6判断
#define kDEVICE_IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)

//iphone5判断
#define kDEVICE_IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//iphone4判断
#define kDEVICE_IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
//iOS7判断
#define kIOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define kIOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0
#define kIOS9 [[[UIDevice currentDevice]systemVersion] floatValue] >= 9.0


#endif

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)

#endif /* MainConfig_h */
