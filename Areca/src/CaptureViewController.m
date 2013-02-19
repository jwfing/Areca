//
//  CaptureViewController.m
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "CaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Utils.h"

@interface CaptureViewController () {
    BOOL _isRecording;
    AVCaptureSession *_captureSession;
    AVAssetWriter *_mediaWriter;
    AVAssetWriterInput *_videoWriteInput;
    AVAssetWriterInput *_audioWriteInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
}

@end

@implementation CaptureViewController

@synthesize progressView, recordButton, previewButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isRecording = NO;
        _captureSession = nil;
        _mediaWriter = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    static int frame = 0;
    CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (frame == 0 && _mediaWriter.status != AVAssetWriterStatusWriting) {
        [_mediaWriter startWriting];
        [_mediaWriter startSessionAtSourceTime:lastSampleTime];
    };
    if (_mediaWriter.status > AVAssetWriterStatusWriting) {
        NSLog(@"Warning: writer status is %d", _mediaWriter.status);
        if (AVAssetWriterStatusFailed == _mediaWriter.status) {
            NSLog(@"Error: %@", _mediaWriter.error);
        }
        return;
    }
    if ([_videoWriteInput isReadyForMoreMediaData]) {
        if (![_videoWriteInput appendSampleBuffer:sampleBuffer]) {
            NSLog(@"Unable to write to video input");
        } else {
            NSLog(@"already write video.");
        }
    }
    frame ++;
    if (frame > 180) {
        [_videoWriteInput markAsFinished];
        [_mediaWriter finishWriting];
        [self startPauseTap:nil];
    }
}

- (void)initMediaWriter
{
    CGSize size = CGSizeMake(300, 300);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    BOOL createFolderResult = [Utils createPathIfNecessary:documentsDirectory];
    if (!createFolderResult) {
        NSLog(@"failed to create directory: %@", documentsDirectory);
    }
    NSString *betaCompressionDirectory = [documentsDirectory stringByAppendingFormat:@"/%@", @"movie.mp4"];
    NSError *error = nil;
    unlink([betaCompressionDirectory UTF8String]);
    _mediaWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:betaCompressionDirectory]
fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(_mediaWriter);
    if (error) {
        NSLog(@"error = %@", [error localizedDescription]);
        return;
    }
    NSDictionary *videoCompressProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithDouble:128.0*1024.0],AVVideoAverageBitRateKey, nil];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   videoCompressProps, AVVideoCompressionPropertiesKey,
                                   nil];
    _videoWriteInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                              outputSettings:videoSettings];
    NSParameterAssert(_videoWriteInput);
    _videoWriteInput.expectsMediaDataInRealTime = YES;
    NSDictionary *sourcePixelBufferAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey,
                                                     nil];
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriteInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDict];
    NSParameterAssert(_videoWriteInput);
    NSParameterAssert([_mediaWriter canAddInput:_videoWriteInput]);
    
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                                         [ NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                         [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                                         [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                                         [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                         nil];
    _audioWriteInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                             outputSettings:audioOutputSettings];
    _audioWriteInput.expectsMediaDataInRealTime = YES;
    [_mediaWriter addInput:_videoWriteInput];
    [_mediaWriter addInput:_audioWriteInput];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (IBAction)startPauseTap:(id)sender {
    if (!_isRecording) {
        NSError *error = nil;
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input) {
            return;
        }
        [_captureSession addInput:input];
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setSampleBufferDelegate:self queue:queue];
        output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                [NSNumber numberWithInt:300], (id)kCVPixelBufferWidthKey,
                                [NSNumber numberWithInt:300], (id)kCVPixelBufferHeightKey,
                                nil];
        [_captureSession addOutput:output];
        [_captureSession commitConfiguration];
        AVCaptureVideoPreviewLayer* preLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        preLayer.frame = CGRectMake(10, 100, 300, 300);
        preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:preLayer];

        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        _isRecording = YES;
        [self initMediaWriter];
        [_captureSession startRunning];
    } else {
        [_captureSession stopRunning];
        _isRecording = NO;
        [recordButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (IBAction)previewTap:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *betaCompressionDirectory = [documentsDirectory stringByAppendingFormat:@"/%@", @"movie.mp4"];
    NSURL *url = [NSURL fileURLWithPath:betaCompressionDirectory];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSLog(@"media file size: %d", [data length]);
    MPMoviePlayerController *movie = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [[movie view] setFrame:self.view.bounds];
    movie.initialPlaybackTime = -1;
    movie.controlStyle = MPMovieControlStyleFullscreen;
    [self.view addSubview:[movie view]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movie];
    [movie play];
}

- (void)myMovieFinishedCallback:(NSNotification*)notify
{
    MPMoviePlayerController *movie = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:movie];
    [movie.view removeFromSuperview];
}
@end
