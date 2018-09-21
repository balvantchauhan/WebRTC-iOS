
#import "AppDelegate.h"

@interface AppDelegate () <WebRTCDelegate> {
    
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
        NSURL* url = [[NSURL alloc] initWithString:@"http://122.161.193.184:3000/"];
        self.socket = [[SocketIOClient alloc] initWithSocketURL:url options:@{@"log": @YES}];
    
        [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"socket connected");
        }];
    
        [self.socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
            double cur = [[data objectAtIndex:0] floatValue];
    
            [self.socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
                [self.socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
            });
    
            [ack with:@[@"Got your currentAmount, ", @"dude"]];
        }];
    
        [self.socket on:@"id" callback:^(NSArray* data, SocketAckEmitter* ack) {
            
            [self.socket emit:@"readyToStream" withItems:@[@{@"name":[[UIDevice currentDevice] name]}]];
        }];
    
        [self.socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSDictionary *dict = [data objectAtIndex:0];
            if ([[dict objectForKey:@"type"] isEqualToString:@"init"]){
                if (!self.object){
                    self.object = [[WebRTC alloc] initWithVideo:YES];
                    self.object.delegate = self;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNewCallObserver object:nil userInfo:@{kPeerID:[[data objectAtIndex:0] objectForKey:@"from"]}];
                    [self.object addPeerConnectionForID:[[data objectAtIndex:0] objectForKey:@"from"]];
                    [self.object createOfferForPeerWithID:[[data objectAtIndex:0] objectForKey:@"from"]];
                }
            }  else if ([[dict objectForKey:@"type"] isEqualToString:@"answer"]) {
                
                NSString *stringSDP = [[dict objectForKey:@"payload"]objectForKey:@"sdp"];
                RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:@"answer" sdp:stringSDP];
                [self.object setRemoteDescription:sessionDescription forPeerWithID:[dict objectForKey:@"from"] receiver:NO];
                
                NSLog(@"");
            }
            else if ([[dict objectForKey:@"type"] isEqualToString:@"candidate"]) {
               
                RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[[dict objectForKey:@"payload"]objectForKey:@"id"] index:[[[dict objectForKey:@"payload"] objectForKey:@"label"] intValue] sdp:[[dict objectForKey:@"payload"] objectForKey:@"candidate"]];
                
                [self.object addICECandidate:candidate forPeerWithID:[dict objectForKey:@"from"]];
                [self.delegate webRTCLocalVideoTrack:[self.object.localMediaStream.videoTracks lastObject]];
                NSLog(@"");
            } else if ([[dict objectForKey:@"type"] isEqualToString:@"offer"]) {
                
             
                [self.object addPeerConnectionForID:[[data objectAtIndex:0] objectForKey:@"from"]];
                
                NSString *stringSDP = [[dict objectForKey:@"payload"]objectForKey:@"sdp"];
                RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:stringSDP];
                [self.object setRemoteDescription:sessionDescription forPeerWithID:[dict objectForKey:@"from"] receiver:YES];
                
                
                NSLog(@"");
            } else if ([[dict objectForKey:@"type"] isEqualToString:@"bye"]){
                
            } else if ([[dict objectForKey:@"type"] isEqualToString:@"ice"]) {
                
            }
        }];
        
    
        [self.socket connect];
    
    
    return YES;
}

- (void)webRTC:(WebRTC *)webRTC didSendSDPOffer:(RTCSessionDescription *)offer forPeerWithID:(NSString *)peerID {
    
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:offer.type forKey:@"type"];
    [dict setObject:offer.description forKey:@"sdp"];
    [self sendeMessage:peerID type:offer.type sdp:dict];
    
    
    NSLog(@"");
}

- (void)webRTC:(WebRTC *)webRTC didSendSDPAnswer:(RTCSessionDescription *)answer forPeerWithID:(NSString* )peerID {
    
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:answer.type forKey:@"type"];
    [dict setObject:answer.description forKey:@"sdp"];
    [self sendeMessage:peerID type:answer.type sdp:dict];
    
    NSLog(@"");
}
- (void)webRTC:(WebRTC *)webRTC didSendICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID {
    
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSString stringWithFormat:@"%@",@(candidate.sdpMLineIndex)] forKey:@"label"];
    [dict setObject:candidate.sdpMid forKey:@"id"];
    [dict setObject:candidate.sdp forKey:@"candidate"];
    [self sendeMessage:peerID type:@"candidate" sdp:dict];
  
    NSLog(@"");
}
- (void)webRTC:(WebRTC *)webRTC didObserveICEConnectionStateChange:(RTCICEConnectionState)state forPeerWithID:(NSString *)peerID {
    if (state == RTCICEConnectionDisconnected){
        [self.object removePeerConnectionForID:peerID];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndCallObserver object:@{kPeerID:peerID}];
    }
    NSLog(@"");
}

- (void)webRTC:(WebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID {
    [self.delegate webRTC:webRTC addedStream:stream forPeerWithID:peerID];
    NSLog(@"");
}
- (void)webRTC:(WebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID {
    
    NSLog(@"");
}

- (void)sendeMessage:(NSString *)idUser type:(NSString *)type sdp:(NSMutableDictionary *)payload {
    
    NSDictionary *dict = @{@"to":idUser,
                           @"type":type,
                           @"payload":payload};
    [self sendToSocket:dict];
}
- (void)sendToSocket:(NSDictionary *)dict {
//    NSError *error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonInterests = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   // NSLog(@"send to socket : %@",jsonInterests);
     [[self socket] emit:@"message" withItems:@[dict]];
    //[[[self appDelegate] socket] writeString:jsonInterests];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
