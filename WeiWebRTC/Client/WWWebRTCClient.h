//
//  WWClient.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/23.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWSignalingClient.h"
#import <WebRTC/RTCVideoRenderer.h>
#import <Vision/Vision.h>
#import "WWFaceDetectionResultsItem.h"

@class RTCVideoCapturer;
NS_ASSUME_NONNULL_BEGIN

@class WWWebRTCClient;

@protocol WWWebRTCClientFaceDetectionDelegate <NSObject>

- (void)WWWebRTCClient:(WWWebRTCClient *)client didReceiveFaceResults:(WWFaceDetectionResultsItem *)results;

@end

@interface WWWebRTCClient : NSObject

@property (strong, nonatomic) WWSignalingClient *signalingClient;

@property (strong, nonatomic) RTCVideoCapturer *videoCapturer;

@property (weak, nonatomic) id<WWWebRTCClientFaceDetectionDelegate> faceDetectionDelegate;

- (void)start;

- (void)renderRemoteVideo:(id<RTCVideoRenderer>)renderer;

- (void)renderLocalVideo:(id<RTCVideoRenderer>)renderer;

- (void)sendFaceBouning:(NSArray<VNFaceObservation *>*)faces;

@end

NS_ASSUME_NONNULL_END
