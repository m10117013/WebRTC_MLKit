//
//  WWSignalingClient.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWSignalingClientConfigure.h"

@class RTCSessionDescription;
@class RTCIceCandidate;
@class WWSignalingClient;

@protocol WWSignalingClientDelegate <NSObject>

- (void)WWSignalingClientReady:(WWSignalingClient *)client;

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieOffer:(RTCSessionDescription *)sdp;

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieAnswer:(RTCSessionDescription *)sdp;

- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieCandidtes:(RTCIceCandidate *)candidtes;

@optional

- (void)WWSignalingClientDidConnect:(WWSignalingClient *)client;

- (void)WWSignalingClientDidClose:(WWSignalingClient *)client;

- (void)WWSignalingClientDidConnect:(WWSignalingClient *)client withError:(NSError *)error;

@end

@interface WWSignalingClient : NSObject

/**
 configure information
 */
@property (copy, nonatomic) id<WWSignalingClientConfigure> configure;

/**
 delegate
 */
@property (weak, nonatomic) id<WWSignalingClientDelegate> delegate;

/**
 init with configure

 @param configure configure
 @return WWSignalingClient
 */
- (instancetype)initWithConfigure:(id<WWSignalingClientConfigure>)configure;

/**
 connect to server
 */
- (void)connect;

/**
 close socket
 */
- (void)close;

- (BOOL)sendAnswer:(RTCSessionDescription *)sdp;

- (BOOL)sendOffer:(RTCSessionDescription *)sdp;
/**
 send candidates to server

 @param sdp <#sdp description#>
 @return <#return value description#>
 */
- (BOOL)sendCandidates:(RTCIceCandidate *)candidate;

@end

