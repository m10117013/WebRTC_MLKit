//
//  ChatViewController.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWChatViewController.h"
#import "WWWebRTCClient.h"
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import "RTCCameraVideoCapturer+FaceDetection.h"
#import "WWFaceDetectionResultsItem.h"
#import "WWFaceDetectionItem.h"

@interface WWChatViewController () <WWWebRTCClientFaceDetectionDelegate> {
    dispatch_queue_t queue;
}

@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;

@property (strong, nonatomic) NSMutableArray<CALayer *> *maskLayers;

@end

@implementation WWChatViewController

- (void)setRtcClient:(WWWebRTCClient *)rtcClient {
    _rtcClient = rtcClient;
    _rtcClient.faceDetectionDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.maskLayers = [[NSMutableArray alloc] init];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.rtcClient renderRemoteVideo:self.remoteVideoView];
    [self.rtcClient renderLocalVideo:self.localView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCCameraVideoCapturer *_captureSession = ((RTCCameraVideoCapturer *)self.rtcClient.videoCapturer);
        if ([_captureSession isKindOfClass:[RTCCameraVideoCapturer class]]) {
            [_captureSession startObserverWithHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                [self removeMaskLayer];
                if (request.results.count <= 0)
                    return;
                [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[VNFaceObservation class]])
                        [self drawFaceboundingBox:[obj boundingBox]];
                }];
                [self.rtcClient sendFaceBouning:request.results];
            }];
        }
    });
}

- (void)drawFaceboundingBox:(CGRect)face {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform, 0, -self.remoteVideoView.frame.size.height);
        CGAffineTransform translate = CGAffineTransformScale(CGAffineTransformIdentity, self.remoteVideoView.frame.size.width, self.remoteVideoView.frame.size.height);
        CGRect rect = CGRectApplyAffineTransform(CGRectApplyAffineTransform(face, translate), transform);
        [self createLayer:rect];
    });
}

- (void)createLayer:(CGRect)rect {
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = rect;
    mask.cornerRadius = 5;
    mask.opacity = 0.5;
    mask.borderColor = UIColor.redColor.CGColor;
    mask.borderWidth = 2.0;
    [self.maskLayers addObject:mask];
    [self.localView.layer insertSublayer:mask atIndex:1];
}

- (void)removeMaskLayer {
    [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
}

- (void)WWWebRTCClient:(nonnull WWWebRTCClient *)client didReceiveFaceResults:(nonnull WWFaceDetectionResultsItem *)result {
    [self removeMaskLayer];
    [result.results enumerateObjectsUsingBlock:^(WWFaceDetectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect face = CGRectMake([obj.x doubleValue], [obj.y doubleValue], [obj.width doubleValue], [obj.height doubleValue]);
        [self drawFaceboundingBox:face];
    }];
    
}

@end
