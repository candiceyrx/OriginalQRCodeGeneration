//
//  UIImage+GenerateQRCode.m
//  二维码生成
//
//  Created by Candice on 16/12/16.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import "UIImage+GenerateQRCode.h"
#import "UIImage+RoundRectImage.h"

@implementation UIImage (GenerateQRCode)

+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString {
    UIImage *result = [self imageOfQRCodeFromURL:urlString codeSize:200 red:0 green:0 blue:0 insertImage:[UIImage imageNamed:@"cesi"] roundRadius:15.0f];
    return result;
}

+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString codeSize:(CGFloat)codeSzie {
    if (!urlString || (NSNull *)urlString == [NSNull null] ) {
        return nil;
    }
    
    codeSzie = [self validateCodeSize:codeSzie];
    CIImage *originImage = [self createQRFromAddress:urlString];
    UIImage *result = [self excludeFuzzyImageFromCIImage:originImage size:codeSzie];
    
    return result;
}

/*自定义二维码颜色的实现思路是，遍历生成的二维码的像素点，将其中为白色的像素点填充为透明色，非白色则填充为我们自定义的颜色。但是，这里的白色并不单单指纯白色，rgb值高于一定数值的灰色我们也可以视作白色处理。在这里我对白色的定义为rgb值高于0xd0d0d0的颜色值为白色，这个值并不是确定的，大家可以自己设置。基于颜色的设置，我们将原有生成二维码的方法接口改成这样
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlSting codeSize:(CGFloat)codeSize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue {
    if (!urlSting || (NSNull *)urlSting == [NSNull null]) {
        return nil;
    }
    
    //颜色不可以太接近白色
    NSUInteger rgb = (red << 16) + (green << 8) +blue;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color of QR code is two close to white color than it will diffculty to scan");
    
    codeSize = [self validateCodeSize:codeSize];
    
    CIImage *originImage = [self createQRFromAddress:urlSting];
    
    UIImage *progressImage = [self excludeFuzzyImageFromCIImage:originImage size:codeSize];//到这里已经可以二维码扫描了
    
    UIImage *effectiveImage = [self imageFillBlackColorAndTransparent:progressImage red:red green:green blue:blue];
    
    return effectiveImage;
}

/* 这时候距离微信还差一小步，我们要在二维码的中心位置插入我们的小头像，最直接的方式是加载完我们的头像后，直接drawInRect:。这种实现方法是正确的，但是在我们画上去之前，我们还需要对图像进行圆角处理。（省事的可能直接用imageView加载头像，然后设置头像的cornerRadius，这个也能实现效果).
 到了这个时候，我们需要一个更多参数的二维码生成方法接口了，这次新增的参数应该包括插入图片、圆角半径这些参数，因此方法如下
 */
+ (UIImage *)imageOfQRCodeFromURL:(NSString *)urlString codeSize:(CGFloat)codeSize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue insertImage:(UIImage *)insertImage roundRadius:(CGFloat)roundRadius {
    if (!urlString || (NSNull *)urlString == [NSNull null]) {
        return nil;
    }
    
    //颜色不可以太接近白色
    NSUInteger rgb = (red << 16) + (green << 8) +blue;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color of QR code is two close to white color than it will diffculty to scan");
    
    codeSize = [self validateCodeSize:codeSize];
    CIImage *originlImage = [self createQRFromAddress:urlString];
    
    UIImage *progressImage = [self excludeFuzzyImageFromCIImage:originlImage size:codeSize];
    UIImage *effectiveImage = [self imageFillBlackColorAndTransparent:progressImage red:red green:green blue:blue];
    
    return [self imageInsertedImage:effectiveImage insertImage:insertImage radius:roundRadius];
}

#pragma mark - Private

//验证二维码尺寸合法性,控制二维码尺寸在合适的范围内
+ (CGFloat)validateCodeSize:(CGFloat)codeSize {
    codeSize = MAX(160, codeSize);
    codeSize = MIN(CGRectGetWidth([UIScreen mainScreen].bounds)-80, codeSize);
    
    return codeSize;
}

//利用系统滤镜生成二维码图，通过链接地址生成原生的二维码图
+ (CIImage *)createQRFromAddress:(NSString *)networkAddress {
    NSData *stringData = [networkAddress dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

//对生成的二维码图片进行清晰化处理
+ (UIImage *)excludeFuzzyImageFromCIImage:(CIImage *)image size:(CGFloat)codeSize {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(codeSize/CGRectGetWidth(extent), codeSize/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    //创建灰度色调空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:scaledImage];
}

//颜色渲染的过程包括获取图像的位图上下文、像素替换、二进制图像转换等操作
+ (UIImage *)imageFillBlackColorAndTransparent:(UIImage *)image red:(NSUInteger )red green:(NSUInteger)green blue:(NSUInteger)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, (CGRect){(CGPointZero),(image.size)}, image.CGImage);
    
    //遍历像素
    int piexlNumber = imageHeight * imageWidth;
    [self fillWhiteToTransparentOnPixel:rgbImageBuf pixelNumber:piexlNumber red:red green:green blue:blue];
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return resultImage;
}

//遍历所有像素点进行颜色替换
+ (void)fillWhiteToTransparentOnPixel:(uint32_t *)rgbImageBuf pixelNumber:(int)pixelNumber red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue {
    uint32_t *pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNumber; i++,pCurPtr++) {
        if ((*pCurPtr & 0xffffff00) < 0xd0d0d000) {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
        } else {
           //将白色变成透明色
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }
}

//回调函数
void ProviderReleaseData(void *info, const void *data,size_t size){
    free((void *)data);
}

//在二维码原图中心位置插入圆角图像
+ (UIImage *)imageInsertedImage:(UIImage *)originImage insertImage:(UIImage *)insertImage radius:(CGFloat)radius {
    if (!insertImage) {
        return originImage;
    }
    
    insertImage = [UIImage imageOfRoundRectWithImage:insertImage size:insertImage.size radius:radius];
    UIImage *whiteBG = [UIImage imageNamed:@"whiteBG"];
    whiteBG = [UIImage imageOfRoundRectWithImage:whiteBG size:whiteBG.size radius:radius];
    //白色边缘宽度
    const CGFloat whiteSize = 2.f;
    CGSize brinkSize = CGSizeMake(originImage.size.width/4, originImage.size.height/4);
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
    CGSize imageSize = CGSizeMake(brinkSize.width - 2*whiteSize, brinkSize.height - 2*whiteSize);
    CGFloat imageX = brinkX + whiteSize;
    CGFloat imageY = brinkY + whiteSize;
    
    UIGraphicsBeginImageContext(originImage.size);
    [originImage drawInRect:(CGRect){0,0,(originImage.size)}];
    [whiteBG drawInRect:(CGRect){brinkX,brinkY,(brinkSize)}];
    [insertImage drawInRect:(CGRect){imageX,imageY,(imageSize)}];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}



@end
