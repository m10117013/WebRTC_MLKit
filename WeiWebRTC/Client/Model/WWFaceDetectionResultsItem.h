//
//  WWFaceDetectionResultsItem.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
@class WWFaceDetectionItem;

NS_ASSUME_NONNULL_BEGIN

@interface WWFaceDetectionResultsItem : MTLModel <MTLJSONSerializing>
/**
 results
 */
@property (copy, nonatomic) NSArray<WWFaceDetectionItem *> *results;
@end

NS_ASSUME_NONNULL_END
