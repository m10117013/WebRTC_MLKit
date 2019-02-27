//
//  MessagingItem.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

/**
 signaling server message types

 - MessagingItemTypeReady: peer ready (can start send offer)
 - MessagingItemTypeOffer: peer offer
 - MessagingItemTypeAnswer: peer answer
 - MessagingItemCandidates: peer candidates
 - MessagingItemUnknow: unknow massage type
 */
typedef NS_ENUM(NSInteger, MessagingItemType) {
    MessagingItemTypeReady,
    MessagingItemTypeOffer,
    MessagingItemTypeAnswer,
    MessagingItemCandidates,
    MessagingItemUnknow
};

@interface WWMessagingItem : MTLModel <MTLJSONSerializing>

/**
 type
 */
@property (assign, nonatomic) MessagingItemType type;

/**
 message
 */
@property (copy, nonatomic) NSString *message;

/**
 decoded message
 */
@property (copy, nonatomic, readonly) NSString *decodedMessage;


- (instancetype)initWithType:(MessagingItemType)type message:(NSString *)msg;

/**
 encode message with base64String
 */
- (NSString *)encode;
@end
