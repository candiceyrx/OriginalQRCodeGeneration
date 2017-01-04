//
//  ViewController.m
//  二维码生成
//
//  Created by Candice on 16/12/16.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+GenerateQRCode.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"生成二维码" forState:UIControlStateNormal];
    button.frame = CGRectMake((self.view.bounds.size.width-100)/2, 100, 100, 80);
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}

- (void)generateQRCode {
    NSLog(@"生成二维码");
    
    //生成正常的清晰二维码
    //UIImage *image = [UIImage imageOfQRCodeFromURL:@"https://www.baidu.com" codeSize:1000];
   
    //生成带颜色的二维码
    //UIImage *image = [UIImage imageOfQRCodeFromURL:@"https://www.baidu.com" codeSize:1000 red:123 green:188 blue:224];
    
    //生成带照片的二维码
    UIImage *image = [UIImage imageOfQRCodeFromURL:@"https://www.baidu.com" codeSize:200 red:0 green:0 blue:0 insertImage:[UIImage imageNamed:@"cesi"] roundRadius:15.0f];
    
    //调这一个接口就行
    //UIImage *image = [UIImage imageOfQRCodeFromURL:@"You are my best friend"];
    CGSize size = image.size;
    NSLog(@"二维码图片的宽:%f,高:%f",size.width,size.height);
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame: ((CGRect){(CGPointZero), (size)})];
    imageView.center = self.view.center;
    imageView.image = image;
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
