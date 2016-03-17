//
//  SZQRScanner.m
//  QRTest
//
//  Created by zzj on 16/3/16.
//  Copyright © 2016年 zzj. All rights reserved.
//

#import "SZQRScanner.h"

#define SZQR_DEFAULT_SCALE 10.0
#define SZQR_DEFAULT_CORRECTIONLEVEL SZQR_LEVEL_M

@interface SZQRScanner () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_deviceInput;
    AVCaptureMetadataOutput *_metadataOutput;
    AVCaptureVideoPreviewLayer *_previewLayer;
}
@end

@implementation SZQRScanner

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _scanRect = frame;
        
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPreset640x480;
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error;
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (_deviceInput) {
            
            [_session addInput:_deviceInput];
            _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [_session addOutput:_metadataOutput];
            _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            
            _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _previewLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            [self.layer addSublayer:_previewLayer];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
                _metadataOutput.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:_scanRect];
            }];
            
        } else {
            NSLog(@"SZQRScanner_Error:%@", error);
        }
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _previewLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setScanRect:(CGRect)scanRect
{
    _scanRect = scanRect;
    
    _metadataOutput.rectOfInterest = CGRectMake(0.0, 0.0, 1.0, 1.0);
}

- (void)requestAccess
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
}

- (void)start
{
    [_session startRunning];
}

- (void)stop
{
    [_session stopRunning];
}

- (void)setSessionPreset:(NSString *)sessionPreset
{
    _session.sessionPreset = sessionPreset;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(szQRScanner:scanString:)]) {
            [self.delegate szQRScanner:self scanString:metadataObject.stringValue];
        }
    }
}

+ (NSString *)realLevelForLevel:(SZQR_LEVEL)level
{
    switch (level) {
        case SZQR_LEVEL_L:
            return @"L";
            break;
        case SZQR_LEVEL_M:
            return @"M";
            break;
        case SZQR_LEVEL_Q:
            return @"Q";
            break;
        case SZQR_LEVEL_H:
            return @"H";
            break;
        default:
            break;
    }
}

+ (UIImage *)makeQRImageWithString:(NSString *)qrString
{
    return [self makeQRImageWithString:qrString correctionLevel:SZQR_DEFAULT_CORRECTIONLEVEL scale:SZQR_DEFAULT_SCALE];
}

+ (UIImage *)makeQRImageWithString:(NSString *)qrString scale:(CGFloat)scale
{
    return [self makeQRImageWithString:qrString correctionLevel:SZQR_DEFAULT_CORRECTIONLEVEL scale:scale];
}

+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level
{
    return [self makeQRImageWithString:qrString correctionLevel:level scale:SZQR_DEFAULT_SCALE];
}

+ (UIImage *)makeQRImageWithString:(NSString *)qrString correctionLevel:(SZQR_LEVEL)level scale:(CGFloat)scale
{
    NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:[self realLevelForLevel:level] forKey:@"inputCorrectionLevel"];  //LMQH
    
    CIImage *outputImage = filter.outputImage;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:transformImage fromRect:transformImage.extent];
    
    UIImage *qrCodeImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return qrCodeImage;
}

+ (NSString *)qrStringFromImage:(UIImage *)image
{
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *img = [[CIImage alloc]initWithImage:image];
    NSArray *features = [detector featuresInImage:img];
    for (CIQRCodeFeature *feature in features) {
        return feature.messageString;
    }
    
    return nil;
}

@end
