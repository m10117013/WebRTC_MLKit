//
//  WWFaceDetectionItem.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/26.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWFaceDetectionItem.h"

@implementation WWFaceDetectionItem


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"x": @"x",
             @"y": @"y",
             @"width": @"w",
             @"height": @"h"
             };
}

- (NSData *)encode {
//    NSDictionary *keys = [WWMessagingItem messagingMapper];
//    __block NSString *messageKey = @"";
//    __weak typeof(self) weakSelf = self;
//    [keys.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([keys[key] integerValue] == weakSelf.type) {
//            messageKey = key;
//        }
//    }];
//
//    NSData *plainData = [self.message dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
//    return [NSString stringWithFormat:@"{\"t\":\"%@\",\"m\":\"%@\"}",messageKey,base64String];
    return nil;
}
@end
