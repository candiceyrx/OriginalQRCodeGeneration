//
//  UIImage+RoundRectImage.h
//  二维码生成
//
//  Created by Candice on 16/12/16.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RoundRectImage)
/**
 *  @author 刘灵
 *
 *  给传入的图片设置圆角后返回圆角图片
 *
 *  @param image  传入的图片
 *  @param size   图片大小
 *  @param radius 圆角半径
 *
 *  @return 圆角图片
 */
+ (UIImage *)imageOfRoundRectWithImage:(UIImage *)image size:(CGSize )size radius:(CGFloat)radius;
@end
