//
//  MessgingItem.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import "WWMessagingItem.h"

@implementation WWMessagingItem

+ (NSDictionary *)messagingMapper {
    return @{
             @"r": @(MessagingItemTypeReady),
             @"o": @(MessagingItemTypeOffer),
             @"a": @(MessagingItemTypeAnswer),
             @"c": @(MessagingItemCandidates)
             };
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"type": @"t",
             @"message": @"m"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:[WWMessagingItem messagingMapper]];
}

- (instancetype)initWithType:(MessagingItemType)type message:(NSString *)msg {
    self = [super init];
    if (self) {
        self.type = type;
        self.message = msg;
    }
    return self;
}

- (NSString *)encode {
    NSDictionary *keys = [WWMessagingItem messagingMapper];
    __block NSString *messageKey = @"";
    __weak typeof(self) weakSelf = self;
    [keys.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([keys[key] integerValue] == weakSelf.type) {
            messageKey = key;
        }
    }];
    
    NSData *plainData = [self.message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"{\"t\":\"%@\",\"m\":\"%@\"}",messageKey,base64String];
}

- (NSString *)decodedMessage {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.message options:0];
    return [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
}
@end
