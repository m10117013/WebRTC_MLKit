//
//  RTCIceCandidate+sss.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import "RTCIceCandidate+WWCandidatesItemTransfer.h"
#import "WWCandidatesItem.h"

@implementation RTCIceCandidate(WWCandidatesItemTransfer)


+ (RTCIceCandidate *)transferWWCandidatesItem2RTCIceCandidate:(WWCandidatesItem *)item {
  return [[RTCIceCandidate alloc] initWithSdp:item.sdp sdpMLineIndex:(int)item.sdpMLineIndex.integerValue sdpMid:item.sdpMid];
}

+ (WWCandidatesItem *)transferRTCIceCandidate2WWCandidatesItem:(RTCIceCandidate *)candidate {
    WWCandidatesItem *item = [[WWCandidatesItem alloc] init];
    item.sdpMid = candidate.sdpMid;
    item.sdpMLineIndex = @(candidate.sdpMLineIndex);
    item.sdp = candidate.sdp;
    return item;
}

@end
