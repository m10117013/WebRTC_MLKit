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

@property (copy, nonatomic) NSNumber *x;

@property (copy, nonatomic) NSNumber *y;

@property (copy, nonatomic) NSNumber *width;

@property (copy, nonatomic) NSNumber *height;
@end

NS_ASSUME_NONNULL_END
