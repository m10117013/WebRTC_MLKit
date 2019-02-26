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

 @param item <#item description#>
 @return <#return value description#>
 */
+ (RTCIceCandidate *)transferWWCandidatesItem2RTCIceCandidate:(WWCandidatesItem *)item;

/**
 transfer RTCIceCandidate to WWCandidatesItem

 @param item <#item description#>
 @return <#return value description#>
 */
+ (WWCandidatesItem *)transferRTCIceCandidate2WWCandidatesItem:(RTCIceCandidate *)item;

@end
