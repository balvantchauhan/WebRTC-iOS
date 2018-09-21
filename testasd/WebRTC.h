
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "RTCSessionDescription.h"
#import "RTCICECandidate.h"
#import "RTCMediaStream.h"
#import "RTCTypes.h"
#import <CoreMedia/CoreMedia.h>
#import "RTCPeerConnectionFactory.h"

@class RTCICEServer;

@class AVCaptureDevice;

@protocol WebRTCDelegate;

@interface WebRTC : NSObject


@property (nonatomic, weak) id <WebRTCDelegate> delegate;



- (instancetype)initWithVideoDevice:(AVCaptureDevice *)device;
- (instancetype)initWithVideo:(BOOL)allowVideo;

- (void)addPeerConnectionForID:(NSString *)identifier;
- (void)removePeerConnectionForID:(NSString *)identifier;

- (void)createOfferForPeerWithID:(NSString *)peerID;
- (void)setRemoteDescription:(RTCSessionDescription *)remoteSDP forPeerWithID:(NSString *)peerID receiver:(BOOL)isReceiver;
- (void)addICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID;
- (void)addICEServer:(RTCICEServer *)server;
@property (strong, nonatomic) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerFactory;
@end

@protocol WebRTCDelegate <NSObject>
@required
- (void)webRTC:(WebRTC *)webRTC didSendSDPOffer:(RTCSessionDescription *)offer forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC didSendSDPAnswer:(RTCSessionDescription *)answer forPeerWithID:(NSString* )peerID;
- (void)webRTC:(WebRTC *)webRTC didSendICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC didObserveICEConnectionStateChange:(RTCICEConnectionState)state forPeerWithID:(NSString *)peerID;

- (void)webRTC:(WebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;

@end
