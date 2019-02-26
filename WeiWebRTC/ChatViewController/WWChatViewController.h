//
//  ChatViewController.h
//  WeiWebRTC
//
//  Created by wei on 2019/2/24.
//  Copyright © 2019 wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WWWebRTCClient;

NS_ASSUME_NONNULL_BEGIN

@interface WWChatViewController : UIViewController

@property (strong, nonatomic) WWWebRTCClient *rtcClient;

@end

NS_ASSUME_NONNULL_END
