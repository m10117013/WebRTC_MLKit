//
//  WWFaceDetectionItem.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

NS_ASSUME_NONNULL_BEGIN

@interface WWFaceDetectionItem : MTLModel <MTLJSONSerializing>

/**
 x
 */
@property (copy, nonatomic) NSNumber *x;

/**
 w
 */
@property (copy, nonatomic) NSNumber *y;

/**
 width
 */
@property (copy, nonatomic) NSNumber *width;

/**
 height
 */
@property (copy, nonatomic) NSNumber *height;
@end

NS_ASSUME_NONNULL_END
