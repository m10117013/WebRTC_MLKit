//
//  RTCIceCandidate+sss.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCIceCandidate.h>
@class WWCandidatesItem;

@interface RTCIceCandidate (WWCandidatesItemTransfer)

/**
 transfer WWCandidatesItem to RTCIceCandidate
 */
+ (RTCIceCandidate *)transferWWCandidatesItem2RTCIceCandidate:(WWCandidatesItem *)item;

/**
 transfer RTCIceCandidate to WWCandidatesItem
 */
- (WWCandidatesItem *)toWWCandidatesItem;

@end
