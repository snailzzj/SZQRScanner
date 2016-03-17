//
//  ViewController.m
//  SZQRScanner
//
//  Created by lyh on 16/3/17.
//  Copyright © 2016年 zzj. All rights reserved.
//

#import "ViewController.h"
#import "SZQRScanner.h"

@interface ViewController () <SZQRScannerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize size = self.view.frame.size;
    
    //识别图片二维码
    NSLog(@"实别图片二维码：%@", [SZQRScanner qrStringFromImage:[UIImage imageNamed:@"QR"]]);
    
    //生成二维码
    UIImage *QR = [SZQRScanner makeQRImageWithString:@"http://www.zzjblog.com/"];
    UIImageView *iv = [[UIImageView alloc]initWithImage:QR];
    iv.frame = CGRectMake(size.width/2-100, 300, 200, 200);
    [self.view addSubview:iv];
    
    //创建二维码扫描器
    SZQRScanner *sz = [[SZQRScanner alloc]initWithFrame:self.view.frame];
    sz.delegate = self;
    sz.scanRect = CGRectMake(size.width/2-100, 100, 200, 200);
    [self.view addSubview:sz];
    [sz start];
    

    
    
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(size.width/2-100, 100, 200, 200)];
    v.backgroundColor = [UIColor whiteColor];
    v.alpha = 0.2;
    [self.view addSubview:v];
}

- (void)szQRScanner:(SZQRScanner *)szQRScanner scanString:(NSString *)result
{
    NSLog(@"扫描结果：%@", result);
    
    [szQRScanner stop];
}

@end
