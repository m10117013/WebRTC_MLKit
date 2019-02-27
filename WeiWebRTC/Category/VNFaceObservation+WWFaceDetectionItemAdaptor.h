//
//  VNFaceObservation+Transfer.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
@class WWFaceDetectionItem;

NS_ASSUME_NONNULL_BEGIN

/**
 adaptor
 */
@interface VNFaceObservation (WWFaceDetectionItemAdaptor)

/**
 transfer to WWFaceDetectionItem

 @return item
 */
- (WWFaceDetectionItem *)toWWFaceDetectionItem;

@end

NS_ASSUME_NONNULL_END
