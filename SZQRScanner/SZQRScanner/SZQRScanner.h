//
//  SZQRScanner.h
//  QRTest
//
//  Created by zzj on 16/3/16.
//  Copyright © 2016年 zzj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, SZQR_LEVEL) {
    SZQR_LEVEL_L,   //7%
    SZQR_LEVEL_M,   //15%
    SZQR_LEVEL_Q,   //25%
    SZQR_LEVEL_H    //30%
};

@class SZQRScanner;

@protocol SZQRScannerDelegate <NSObject>
- (void)szQRScanner:(SZQRScanner *)szQRScanner scanString:(NSString *)result;
@end


@interface SZQRScanner : UIView

@property (weak, nonatomic) id<SZQRScannerDelegate> delegate;
@property (nonatomic) CGRect scanRect;

- (void)requestAccess;

- (void)start;
- (void)stop;

//default is AVCaptureSessionPreset640x480
- (void)setSessionPreset:(NSString *)sessionPreset;

+ (UIImage *)makeQRImageWithString:(NSString *)qrString;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString scale:(CGFloat)scale;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level;
+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level scale:(CGFloat)scale;

//the method must need iOS8
+ (NSString *)qrStringFromImage:(UIImage *)image;

@end
