
#import "ViewController.h"
#import "AppDelegate.h"
#import "WebRTC.h"

@interface ViewController () <MyCustomDelegate,RTCEAGLVideoViewDelegate,RTCMediaStreamTrackDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self appDelegate].delegate = self;
 
    [self.localView setFrame:self.view.frame];
 
    [self.remoteView setDelegate:self];
    [self.localView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self showLocalStreem];
    
    if (self.needCall)
        [self mackeCall:self.callToUser];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"EndCall" style:UIBarButtonItemStylePlain target:self action:@selector(endCall)]];
}

- (void)showLocalStreem {
    
    self.localVideoTrack = [[[[[self appDelegate] object] localMediaStream] videoTracks] lastObject] ;
    [self.localVideoTrack addRenderer:self.localView];
    
}
- (void)mediaStreamTrackDidChange:(RTCMediaStreamTrack*)mediaStreamTrack {
    
    
}
-(void)webRTC:(WebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        RTCVideoTrack * remoteVideoTrack = stream.videoTracks[0];
        self.remoteVideoTrack = remoteVideoTrack;
        self.remoteVideoTrack.delegate = self;
        [self.remoteVideoTrack addRenderer:self.remoteView];
        [self.localView setFrame:CGRectMake(self.view.frame.size.width-100, self.view.frame.size.height-120, 100, 120)];
        

        
        
    });
    
 
    
    
    
}


- (void)webRTCLocalVideoTrack:(RTCVideoTrack *)localTrack {
    
   
}
-(void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"videoView ?");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)mackeCall:(NSString *)idUser {
    
    self.needCall = NO;
    NSDictionary *dict = @{@"to":idUser,
                           @"type":@"init"};
    [self sendToSocket:dict];

    
}

- (void)sendToSocket:(NSDictionary *)dict {
    [[[self appDelegate] socket] emit:@"message" withItems:@[dict]];
}
- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endCall)
                                                 name:kEndCallObserver
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)endCall{
    [[[self appDelegate] object] removePeerConnectionForID:self.callToUser];
    [self.remoteVideoTrack removeRenderer:self.remoteView];
    [self.localVideoTrack removeRenderer:self.localView];
    [self.navigationController popViewControllerAnimated:YES];
    [[self appDelegate] setObject:nil];
}
@end
