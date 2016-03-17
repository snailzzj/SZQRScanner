# SZQRScanner

创建二维码扫描器
----------------

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];

    SZQRScanner *sz = [[SZQRScanner alloc]initWithFrame:self.view.frame];
    sz.delegate = self;
    sz.scanRect = CGRectMake(size.width/2-100, 100, 200, 200);  //实际有效扫描区域，默认为frame的大小
    [self.view addSubview:sz];
    [sz start];
}

#pragma mark - SZQRScannerDelegate
- (void)szQRScanner:(SZQRScanner *)szQRScanner scanString:(NSString *)result
{
    NSLog(@"扫描结果：%@", result);
    [szQRScanner stop];   //扫描完成需要停止，否则不会暂停
}
```

生成二维码图片
----------------
```Objective-C
//simple
+ (UIImage *)makeQRImageWithString:(NSString *)qrString;

//more...
//scale：二维码放大比例
//correctionLevel：二维码图片容错率
+ (UIImage *)makeQRImageWithString:(NSString *)qrString;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString scale:(CGFloat)scale;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level scale:(CGFloat)scale;
```

识别二维码图片，需要iOS8
----------------
```Objective-C
+ (NSString *)qrStringFromImage:(UIImage *)image;
```
