//
//  RTCCameraVideoCapturer+SplitData.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/25.
//  Copyright © 2019 wei. All rights reserved.
//

#import "RTCCameraVideoCapturer+FaceDetection.h"
#import <JRSwizzle/JRSwizzle.h>
#import <Vision/Vision.h>
#import <objc/runtime.h>

@interface RTCCameraVideoCapturer (FaceDetection_private)

@property (nonatomic, strong) VNRequest *faceDetectionRequest;

@end

@implementation RTCCameraVideoCapturer (FaceDetection)

+ (void)load {
    NSError *error = nil;
    if (![self jr_swizzleMethod:@selector(captureOutput:didOutputSampleBuffer:fromConnection:) withMethod:@selector(ss_captureOutput:didOutputSampleBuffer:fromConnection:) error:&error]) {
        NSAssert(false, @"error jr_swizzleMethod RTCCameraVideoCapturer with error %@",[error localizedDescription]);
    }
}

- (VNRequest *)faceDetectionRequest {
    return objc_getAssociatedObject(self, @selector(faceDetectionRequest));
}

- (void)setFaceDetectionRequest:(VNRequest *)value {
    objc_setAssociatedObject(self, @selector(faceDetectionRequest), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)startObserverWithHandler:(VNRequestCompletionHandler)handler {
    self.faceDetectionRequest = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:handler];
}

- (void)stopObserver {
    self.faceDetectionRequest = nil;
}

- (void)ss_captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    [self ss_captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    
    if (self.faceDetectionRequest) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationRight options:@{}];
        NSError *error;

        [imageRequestHandler performRequests:@[self.faceDetectionRequest] error:&error];
    }
}


@end
