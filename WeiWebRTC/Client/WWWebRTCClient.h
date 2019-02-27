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

@class RTCConfiguration;
@class RTCVideoCapturer;
@class WWWebRTCClient;

/* NotificationEvent
 kWWWebRTCClientNotificationReady on remote online
 kWWWebRTCClientNotificationPeerLeave is leave room or disconnect
 kWWWebRTCClientNotificationBeCall on remote called
 */
extern NSString const *kWWWebRTCClientNotificationReady;
extern NSString const *kWWWebRTCClientNotificationPeerLeave;
extern NSString const *kWWWebRTCClientNotificationBeCall;

@protocol WWWebRTCClientFaceDetectionDelegate <NSObject>
/**
 faceDetection event
 */
- (void)WWWebRTCClient:(WWWebRTCClient *)client didReceiveFaceResults:(WWFaceDetectionResultsItem *)results;
@end

@interface WWWebRTCClient : NSObject

@property (strong, nonatomic) WWSignalingClient *signalingClient;

/**
 videoCapturer
 */
@property (strong, nonatomic) RTCVideoCapturer *videoCapturer;

/**
 delegate of face detection
 */
@property (weak, nonatomic) id<WWWebRTCClientFaceDetectionDelegate> faceDetectionDelegate;

/**
 init
 */
- (instancetype)init;

/**
 init with signaling client
 */
- (instancetype)initWithSignalingClient:(WWSignalingClient *)client;

/**
 init with signaling client and configuration
 */
- (instancetype)initWithSignalingClient:(WWSignalingClient *)client configuration:(RTCConfiguration *)configuration;

/**
 start service
 */
- (void)start;

/**
 close service
 */
- (void)close;

/**
 send offer (call remote)
 */
- (void)sentOffer;

/**
 binding render with remote viedeo
 */
- (void)renderRemoteVideo:(id<RTCVideoRenderer>)renderer;

/**
 binding render with local viedeo
 */
- (void)renderLocalVideo:(id<RTCVideoRenderer>)renderer;

/**
 send FaceBouning to remote side

 @param faces VNFaceObservation items
 */
- (void)sendFaceBouning:(NSArray<VNFaceObservation *>*)faces;

@end
