//
//  ViewController.m
//  WeiWebRTC
//
//  Created by wei on 2019/2/23.
//  Copyright © 2019 wei. All rights reserved.
//

#import "ViewController.h"
#import "WWWebRTCClient.h"
#import "WWChatViewController.h"

@interface ViewController ()

@property (strong, nonatomic) WWWebRTCClient *client;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [[WWWebRTCClient alloc] init];
    [self.client start];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[WWChatViewController class]]) {
        ((WWChatViewController *)segue.destinationViewController).rtcClient = self.client;
    }
}

@end
