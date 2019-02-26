//
//  WWFaceDetectionResultsItem.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWFaceDetectionResultsItem.h"
#import "WWFaceDetectionItem.h"

@implementation WWFaceDetectionResultsItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"results": @"r"
             };
}

+ (NSValueTransformer *)resultsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[WWFaceDetectionItem class]];
}
@end
