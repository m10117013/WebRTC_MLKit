//
//  WWClient.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/23.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWWebRTCClient.h"

#import "Mantle.h"

#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCPeerConnectionFactory.h>

#import <WebRTC/RTCVideoCapturer.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCMediaStream.h>

#import <WebRTC/RTCDataChannelConfiguration.h>

#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>

#import <WebRTC/RTCFileVideoCapturer.h>
#import <WebRTC/RTCCameraVideoCapturer.h>

#import "VNFaceObservation+WWFaceDetectionItemAdaptor.h"
#import "WWFaceDetectionResultsItem.h"

#define WWCLOG(fmt, ...) NSLog(@"WWCLOG : %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])

NSString const *kWWWebRTCClientNotificationReady = @"WWWebRTCClientNotification_readyForCall";

NSString const *kWWWebRTCClientNotificationBeCall = @"WWWebRTCClientNotification_BeCall";

NSString const *kWWWebRTCClientNotificationPeerLeave = @"WWWebRTCClientNotification_leave";


@interface WWWebRTCClient () <RTCPeerConnectionDelegate,WWSignalingClientDelegate,RTCDataChannelDelegate>

@property (strong, nonatomic) RTCConfiguration *configuration;
@property (strong, nonatomic) RTCPeerConnection *peerConection;

#pragma mark dataChannel

@property (strong, nonatomic) RTCDataChannel *localDataChannel;
@property (strong, nonatomic) RTCDataChannel *remoteDataChannel;

#pragma mark media track
@property (strong, nonatomic) RTCAudioTrack *audioTrack;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@end
@implementation WWWebRTCClient

- (void)setSignalingClient:(WWSignalingClient *)signalingClient {
    _signalingClient = signalingClient;
    _signalingClient.delegate = self;
}

- (instancetype)init {
    //default signalingClient
    WWSignalingClient *signalingClient = [[WWSignalingClient alloc] init];
    return [self initWithSignalingClient:signalingClient];
}

- (instancetype)initWithSignalingClient:(WWSignalingClient *)client {
    //default RTCConfiguration
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    
    config.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302",
                                                                     @"stun:stun1.l.google.com:19302"]]];
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    config.continualGatheringPolicy = RTCContinualGatheringPolicyGatherContinually;
    return [self initWithSignalingClient:client configuration:config];
}

- (instancetype)initWithSignalingClient:(WWSignalingClient *)client configuration:(RTCConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.signalingClient = client;
        self.configuration = configuration;
        
        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:@{@"DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue}];
        
        RTCPeerConnectionFactory *factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:[RTCDefaultVideoEncoderFactory new] decoderFactory:[RTCDefaultVideoDecoderFactory new]];
        
        self.peerConection = [factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
        
        constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
        
        RTCAudioSource *asource = [factory audioSourceWithConstraints:constraints];
        self.audioTrack = [factory audioTrackWithSource:asource trackId:@"audio0"];
        
        [self.peerConection addTrack: self.audioTrack streamIds:@[@"stream"]];
        
        RTCVideoSource *vsource = [factory videoSource];
#if TARGET_OS_SIMULATOR
        self.videoCapturer = [[RTCFileVideoCapturer alloc] initWithDelegate:vsource];
#else
        self.videoCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:vsource];
#endif
        
        self.localVideoTrack = [factory videoTrackWithSource:vsource trackId:@"video0"];
        [self.peerConection addTrack: self.localVideoTrack streamIds:@[@"stream"]];
        
        self.localDataChannel = [self createDataChannel];
        self.localDataChannel.delegate = self;
    }
    return self;
}

- (void)start {
    [self.signalingClient connect];
}

- (void)close {
    [self.peerConection close];
    [self.signalingClient close];
}

- (void)sentOffer {
    NSDictionary *mediaConstrains = @{kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mediaConstrains optionalConstraints:nil];
    __weak typeof(self) weakSelf = self;
    [self.peerConection offerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        [weakSelf.peerConection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            NSAssert((error == nil), error.description);
        }];
        
        [self.signalingClient sendOffer:sdp];
        WWCLOG(@"sent offer sdp...");
    }];
}

- (void)renderRemoteVideo:(id<RTCVideoRenderer>)renderer {
    [self.remoteVideoTrack addRenderer:renderer];
}

- (void)renderLocalVideo:(id<RTCVideoRenderer>)renderer {
    __block AVCaptureDevice *fontCamera;
    
    if (![self.videoCapturer isKindOfClass:[RTCCameraVideoCapturer class]]) {
        return;
    }
    
    [RTCCameraVideoCapturer.captureDevices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.position == AVCaptureDevicePositionFront) {
           fontCamera = obj;
           *stop = YES;
        }
    }];
    
    AVCaptureDeviceFormat *format = [RTCCameraVideoCapturer supportedFormatsForDevice:fontCamera].firstObject;
    
    [((RTCCameraVideoCapturer *)self.videoCapturer) startCaptureWithDevice:fontCamera format:format fps:format.videoSupportedFrameRateRanges.lastObject];
    
    [self.localVideoTrack addRenderer:renderer];
}

- (void)sendFaceBouning:(NSArray<VNFaceObservation *>*)faces {
    NSMutableArray *array = [NSMutableArray new];
    [faces enumerateObjectsUsingBlock:^(VNFaceObservation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject: [obj toWWFaceDetectionItem]];
    }];
    WWFaceDetectionResultsItem *request = [WWFaceDetectionResultsItem new];
    request.results = [array copy];
    NSData *data = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:request] options:NSJSONWritingPrettyPrinted error:nil];
    [self.remoteDataChannel sendData:[[RTCDataBuffer alloc] initWithData:data isBinary:NO]];
}

#pragma mark - privte method

- (void)sentAns {
    NSDictionary *mediaConstrains = @{kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                      kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mediaConstrains optionalConstraints:nil];
    __weak typeof(self) weakSelf = self;
    [self.peerConection answerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        [weakSelf.peerConection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            NSAssert((error == nil), error.description);
        }];
        [self.signalingClient sendAnswer:sdp];
    }];
}

- (RTCDataChannel *)createDataChannel {
    RTCDataChannelConfiguration *configuration = [[RTCDataChannelConfiguration alloc] init];
    return [self.peerConection dataChannelForLabel:@"dataChannel" configuration:configuration];
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    if ([stream videoTracks]) {
        self.remoteVideoTrack = [[stream videoTracks] firstObject];
    }
    WWCLOG(@"didAddStream");
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    //TODO: this is ice status
    WWCLOG(@"didChangeIceConnectionState %ld",(long)newState);
    if (newState == RTCIceConnectionStateClosed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kWWWebRTCClientNotificationPeerLeave object:nil];
        });
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    WWCLOG(@"didChangeIceGatheringState %ld",(long)newState);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    WWCLOG(@"didChangeSignalingState %ld",(long)stateChanged);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    [self.signalingClient sendCandidates:candidate];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel {
    self.remoteDataChannel = dataChannel;
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    WWCLOG(@"did remove stream");
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection {
    WWCLOG(@"peerConnectionShouldNegotiate");
}

#pragma mark - WWSignalingClientDelegate

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieCandidtes:(RTCIceCandidate *)Candidates {
    [self.peerConection addIceCandidate:Candidates];
}

- (void)WWSignalingClientReady:(WWSignalingClient *)client {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kWWWebRTCClientNotificationReady object:nil];
    });
}

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieAnswer:(RTCSessionDescription *)sdp {
    [self.peerConection setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (error) {
             WWCLOG(@"didRecevieAnswer error %@",[error localizedDescription]);
        }
    }];
}

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieOffer:(RTCSessionDescription *)sdp {
    [self.peerConection setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (error) {
            WWCLOG(@"didRecevieOffer error %@",[error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter] postNotificationName:kWWWebRTCClientNotificationBeCall object:nil];
        });
       
    }];
    [self sentAns];
}

#pragma mark - RTCDataChannelDelegate

- (void)dataChannel:(nonnull RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(nonnull RTCDataBuffer *)buffer {
    
    NSData *data = buffer.data;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSError *error = nil;
    WWFaceDetectionResultsItem *item = [MTLJSONAdapter modelOfClass:WWFaceDetectionResultsItem.class fromJSONDictionary:json error:&error];
    
    if (!error) {
        if (self.faceDetectionDelegate && [self.faceDetectionDelegate respondsToSelector:@selector(WWWebRTCClient:didReceiveFaceResults:)]) {
            [self.faceDetectionDelegate WWWebRTCClient:self didReceiveFaceResults:item];
        }
    } else {
        WWCLOG(@"didReceiveMessageWithBuffer error %@",[error localizedDescription]);
    }
}

- (void)dataChannelDidChangeState:(nonnull RTCDataChannel *)dataChannel {
    WWCLOG(@"dataChannelDidChangeState");
    self.remoteDataChannel = dataChannel;
}

@end
