//
//  WWCandidatesItem.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

NS_ASSUME_NONNULL_BEGIN

@interface WWCandidatesItem : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic) NSString *sdpMid;

@property (copy, nonatomic) NSNumber *sdpMLineIndex;

@property (copy, nonatomic) NSString *sdp;

@end

NS_ASSUME_NONNULL_END
