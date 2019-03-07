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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCCameraVideoCapturer *_captureSession = ((RTCCameraVideoCapturer *)weakSelf.rtcClient.videoCapturer);
        if ([_captureSession isKindOfClass:[RTCCameraVideoCapturer class]]) {
            [_captureSession startObserverWithHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                if (weakSelf.showBoundingBoxInLocalView) {
                    [weakSelf removeMaskLayer];
                    [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[VNFaceObservation class]])
                            [weakSelf drawFaceboundingBox:[obj boundingBox] in:weakSelf.localView];
                    }];
                }
                [weakSelf.rtcClient sendFaceBouning:request.results];
            }];
        }
    });
}

- (void)drawFaceboundingBox:(CGRect)face in:(UIView *)view {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize imageSize = view.frame.size;
        CGFloat w = face.size.width * imageSize.width;
        CGFloat h = face.size.height * imageSize.height;
        CGFloat x = face.origin.x * imageSize.width;
        CGFloat y = imageSize.height * (1 - face.origin.y - face.size.height);//- (boundingBox.origin.y * imageSize.height) - h;
        [weakSelf createLayer:CGRectMake(x, y, w, h) in:view.layer];
    });
}

- (void)createLayer:(CGRect)rect in:(CALayer *)layer {
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = rect;
    mask.cornerRadius = 5;
    mask.opacity = 0.5;
    mask.borderColor = UIColor.redColor.CGColor;
    mask.borderWidth = 2.0;
    @synchronized (self.maskLayers) {
        [self.maskLayers addObject:mask];
    };
    [layer insertSublayer:mask atIndex:2];
}

- (void)removeMaskLayer {
    @synchronized (self.maskLayers) {
        [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [obj removeFromSuperlayer];
            });
        }];
        [self.maskLayers removeAllObjects];
    }
}

- (void)WWWebRTCClient:(nonnull WWWebRTCClient *)client didReceiveFaceResults:(nonnull WWFaceDetectionResultsItem *)result {
    __weak typeof(self) weakSelf = self;
    [self removeMaskLayer];
    [result.results enumerateObjectsUsingBlock:^(WWFaceDetectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect face = CGRectMake([obj.x doubleValue], [obj.y doubleValue], [obj.width doubleValue], [obj.height doubleValue]);
        [weakSelf drawFaceboundingBox:face in:weakSelf.remoteVideoView];
   }];
}

@end
