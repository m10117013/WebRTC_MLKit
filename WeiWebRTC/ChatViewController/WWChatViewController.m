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

@interface WWChatViewController () <WWWebRTCClientFaceDetectionDelegate>

@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;

@property (strong, nonatomic) NSMutableArray<CALayer *> *maskLayers;

@property (assign, nonatomic) BOOL showBoundingBoxInLocalView;

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
    [self startObseverFace];
}

- (void)startObseverFace {
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCCameraVideoCapturer *_captureSession = ((RTCCameraVideoCapturer *)self.rtcClient.videoCapturer);
        if ([_captureSession isKindOfClass:[RTCCameraVideoCapturer class]]) {
            [_captureSession startObserverWithHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                if (request.results.count <= 0)
                    return;
                
                if (self.showBoundingBoxInLocalView) {
                    [self removeMaskLayer];
                    [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[VNFaceObservation class]])
                            [self drawFaceboundingBox:[obj boundingBox] in:self.localView];
                    }];
                }
                [self.rtcClient sendFaceBouning:request.results];
            }];
        }
    });
}

- (void)drawFaceboundingBox:(CGRect)face in:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize imageSize = view.frame.size;
        CGFloat w = face.size.width * imageSize.width;
        CGFloat h = face.size.height * imageSize.height;
        CGFloat x = face.origin.x * imageSize.width;
        CGFloat y = imageSize.height * (1 - face.origin.y - face.size.height);//- (boundingBox.origin.y * imageSize.height) - h;
        [self createLayer:CGRectMake(x, y, w, h) in:view.layer];
    });
}

- (void)createLayer:(CGRect)rect in:(CALayer *)layer {
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = rect;
    mask.cornerRadius = 5;
    mask.opacity = 0.5;
    mask.borderColor = UIColor.redColor.CGColor;
    mask.borderWidth = 2.0;
    [self.maskLayers addObject:mask];
    [layer insertSublayer:mask atIndex:2];
}

- (void)removeMaskLayer {
    [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
}

- (void)WWWebRTCClient:(nonnull WWWebRTCClient *)client didReceiveFaceResults:(nonnull WWFaceDetectionResultsItem *)result {
    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf removeMaskLayer];
//    });
    [self removeMaskLayer];
    [result.results enumerateObjectsUsingBlock:^(WWFaceDetectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect face = CGRectMake([obj.x doubleValue], [obj.y doubleValue], [obj.width doubleValue], [obj.height doubleValue]);
        [weakSelf drawFaceboundingBox:face in:self.remoteVideoView];
   }];
}

@end
