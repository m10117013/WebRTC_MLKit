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

/**
 on remote is ready for connecting
 */
- (void)WWSignalingClientReady:(WWSignalingClient *)client;

/**
 on did receive offer
 */
- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieOffer:(RTCSessionDescription *)sdp;

/**
 on did receive answer
 */
- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieAnswer:(RTCSessionDescription *)sdp;

/**
 on did receive candidates
 */
- (void)WWSignalingClient:(WWSignalingClient *)client didRecevieCandidtes:(RTCIceCandidate *)Candidates;

@optional
/**
 client did connect to server
 */
- (void)WWSignalingClientDidConnect:(WWSignalingClient *)client;
//client did close
/**
 client did close
 */
- (void)WWSignalingClientDidClose:(WWSignalingClient *)client;

/**
 client did connect with error
 */
- (void)WWSignalingClientDidConnect:(WWSignalingClient *)client withError:(NSError *)error;
@end

@interface WWSignalingClient : NSObject

/**
 configure information
 */
@property (strong, nonatomic) id<WWSignalingClientConfigure> configure;

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

/**
 send answer to server
 */
- (BOOL)sendAnswer:(RTCSessionDescription *)sdp;

/**
 send offer to server
 */
- (BOOL)sendOffer:(RTCSessionDescription *)sdp;

/**
 send candidates to server
 */
- (BOOL)sendCandidates:(RTCIceCandidate *)candidate;

@end

