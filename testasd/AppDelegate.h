

#import <UIKit/UIKit.h>
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
#import "WebRTC.h"
static NSString * const kNewCallObserver = @"kNewCallObserver";
static NSString * const kEndCallObserver = @"kEndCallObserver";
static NSString * const kPeerID = @"kPeerID";
@protocol MyCustomDelegate;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, weak) id <MyCustomDelegate> delegate;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SocketIOClient* socket ;
@property (strong, nonatomic) WebRTC *object;

@end

@protocol MyCustomDelegate <NSObject>
- (void)webRTC:(WebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
- (void)webRTCLocalVideoTrack:(RTCVideoTrack *)localTrack;
@end