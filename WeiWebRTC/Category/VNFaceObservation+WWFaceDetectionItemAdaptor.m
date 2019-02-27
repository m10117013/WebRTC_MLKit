//
//  VNFaceObservation+Transfer.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import "VNFaceObservation+WWFaceDetectionItemAdaptor.h"
#import "WWFaceDetectionItem.h"

@implementation VNFaceObservation (WWFaceDetectionItemAdaptor)

- (WWFaceDetectionItem *)toWWFaceDetectionItem {
    WWFaceDetectionItem *item = [WWFaceDetectionItem new];
    item.x = @(self.boundingBox.origin.x);
    item.y = @(self.boundingBox.origin.y);
    item.width = @(self.boundingBox.size.width);
    item.height = @(self.boundingBox.size.height);
    return item;
}

@end
