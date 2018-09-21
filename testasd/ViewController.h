
#import <UIKit/UIKit.h>
#import "WebRTC.h"

#import <libjingle_peerconnection/RTCVideoCapturer.h>
#import <libjingle_peerconnection/RTCOpenGLVideoRenderer.h>
#import <libjingle_peerconnection/RTCVideoTrack.h>
#import <libjingle_peerconnection/RTCEAGLVideoView.h>
#import <libjingle_peerconnection/RTCI420Frame.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (strong, nonatomic) NSString *callToUser;
@property (assign, nonatomic) BOOL needCall;
@end

