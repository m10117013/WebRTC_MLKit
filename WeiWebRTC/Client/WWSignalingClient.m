//
//  WWSignalingClient.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#define SSWCLOG(fmt, ...) NSLog(@"SSWCLOG : %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])


#import "WWSignalingClient.h"
#import "SRWebSocket.h"
#import "WWDefaultSignalingClientConfigure.h"

#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCIceCandidate.h>

#import "RTCIceCandidate+WWCandidatesItemTransfer.h"
#import "WWMessagingItem.h"
#import "WWCandidatesItem.h"

@interface WWSignalingClient ()<SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *webSocketClient;

@end

@implementation WWSignalingClient

- (id<WWSignalingClientConfigure>)configure {
    if (!_configure) {
        //if don't assign configure using default configure
        _configure = [[WWDefaultSignalingClientConfigure alloc] init];
    }
    return _configure;
}

- (instancetype)initWithConfigure:(id<WWSignalingClientConfigure>)configure {
    self = [super init];
    if (self) {
        self.configure = configure;
    }
    return self;
}

- (void)connect {
    if (self.webSocketClient) {
        [self.webSocketClient close];
    }
    SSWCLOG(@"connect to signaling server with info : %@",[self.configure signalingServerInfo]);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:[self.configure signalingServerInfo]]];
    self.webSocketClient = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocketClient.delegate = self;
    [self.webSocketClient open];
}

- (void)close {
    SSWCLOG(@"class close method");
    if (self.webSocketClient) {
        [self.webSocketClient close];
        self.webSocketClient.delegate = nil;
        self.webSocketClient = nil;
    }
}

- (BOOL)sendAnswer:(RTCSessionDescription *)sdp {
    return [self sendData:[[WWMessagingItem alloc] initWithType:MessagingItemTypeAnswer message:sdp.sdp]];
}

- (BOOL)sendOffer:(RTCSessionDescription *)sdp {
    return [self sendData:[[WWMessagingItem alloc] initWithType:MessagingItemTypeOffer message:sdp.sdp]];
}

- (BOOL)sendCandidates:(RTCIceCandidate *)candidate {
    WWCandidatesItem *item = [candidate toWWCandidatesItem];
    NSData *data = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:item] options:NSJSONWritingPrettyPrinted error:nil];
    return  [self sendData:[[WWMessagingItem alloc] initWithType:MessagingItemCandidates message: [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]]];
}


- (BOOL)sendData:(WWMessagingItem *)item {
    SSWCLOG(@"send Data type : %ld",item.type);
    if (!self.webSocketClient) {
        return NO;
    }
    [self.webSocketClient send: [item encode]];
    return YES;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    SSWCLOG(@"on data :%@",message);
    if (!self.delegate)
        return;
    
    if ([message isKindOfClass:[NSString class]]) {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *error = nil;
        WWMessagingItem *messageItem = [MTLJSONAdapter modelOfClass:WWMessagingItem.class fromJSONDictionary:json error:&error];
        NSAssert(messageItem != nil, @"error on parsing message item");
        
        if (messageItem.type == MessagingItemTypeReady) {
            [self.delegate WWSignalingClientReady:self];
        } else if (messageItem.type == MessagingItemTypeOffer) {
            [self.delegate WWSignalingClient:self didRecevieOffer:[[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:messageItem.decodedMessage]];
        } else if (messageItem.type == MessagingItemTypeAnswer) {
            [self.delegate WWSignalingClient:self didRecevieAnswer:[[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:messageItem.decodedMessage]];
        } else if (messageItem.type == MessagingItemCandidates) {
            data = [messageItem.decodedMessage dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             WWCandidatesItem *item = [MTLJSONAdapter modelOfClass:WWCandidatesItem.class fromJSONDictionary:json error:&error];
            [self.delegate WWSignalingClient:self didRecevieCandidtes:[RTCIceCandidate transferWWCandidatesItem2RTCIceCandidate:item]];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if (self.delegate && [self.delegate respondsToSelector:@selector(WWSignalingClientDidConnect:)]) {
        [self.delegate WWSignalingClientDidConnect:self];
    }
    SSWCLOG(@"webSocket did-open");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(WWSignalingClientDidConnect:withError:)]) {
        [self.delegate WWSignalingClientDidConnect:self withError:error];
    }
    SSWCLOG(@"webSocket did-error");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean; {
    if (self.delegate && [self.delegate respondsToSelector:@selector(WWSignalingClientDidClose:)]) {
        [self.delegate WWSignalingClientDidClose:self];
    }
    SSWCLOG(@"webSocket did-close");
}


@end
