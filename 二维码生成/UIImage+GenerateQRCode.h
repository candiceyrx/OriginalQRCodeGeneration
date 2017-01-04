//
//  UIImage+GenerateQRCode.h
//  二维码生成
//
//  Created by Candice on 16/12/16.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface UIImage (GenerateQRCode)

/**
 *  @author 刘灵
 *
 *  生成二维码
 *
 *  @param urlString 生成二维码的URL地址
 *  @param codeSzie  二维码的大小
 *
 *  @return 生成的二维码图像
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString codeSize:(CGFloat)codeSzie;

/**
 *  @author 刘灵
 *
 *  生成带颜色渲染的二维码
 *
 *  @param urlSting 生成二维码的URL地址
 *  @param codeSize 二维码的float值
 *  @param red      红
 *  @param green    绿
 *  @param blue     蓝
 *
 *  @return 生成带颜色的二维码
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlSting codeSize:(CGFloat)codeSize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;

/**
 *  @author 刘灵
 *
 *  生成带圆角照片的二维码
 *
 *  @param urlString   生成二维码的URL地址
 *  @param codeSize    二维码的float值
 *  @param red         红
 *  @param green       绿
 *  @param blue        蓝
 *  @param insertImage 要插入的照片
 *  @param roundRadius 圆角半径
 *
 *  @return 类似微信二维码
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString codeSize:(CGFloat)codeSize red:(NSUInteger)red green:(NSUInteger)green blue :(NSUInteger)blue insertImage:(UIImage *)insertImage roundRadius:(CGFloat)roundRadius;

/**
 *  @author 刘灵
 *
 *  再次封装，需要带照片的二维码时，调用，返回生成的二维码图片
 *
 *  @param urlString 生成二维码的URL地址
 *
 *  @return 二维码
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString;

@end
