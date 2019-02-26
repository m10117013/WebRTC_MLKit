//
//  WWSignalingClientConfigure.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol WWSignalingClientConfigure <NSObject>

/**
 e.g @"127.0.0.1:8080"
 */
- (NSString *)SignalingServerInfo;

@end
