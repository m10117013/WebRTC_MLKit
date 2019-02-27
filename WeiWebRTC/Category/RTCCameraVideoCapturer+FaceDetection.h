//
//  RTCCameraVideoCapturer+SplitData.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/25.
//  Copyright © 2019 wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN

/**
 FaceDetection
 */
@interface RTCCameraVideoCapturer (FaceDetection)

/**
 start observer
 */
- (void)startObserverWithHandler:(VNRequestCompletionHandler)handler;

/**
 stop observer
 */
- (void)stopObserver;

@end

NS_ASSUME_NONNULL_END
