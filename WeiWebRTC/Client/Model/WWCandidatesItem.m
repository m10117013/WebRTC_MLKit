//
//  WWCandidatesItem.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWCandidatesItem.h"

@implementation WWCandidatesItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"sdpMid": @"m",
             @"sdpMLineIndex": @"i",
             @"sdp" : @"s"
             };
}


@end
