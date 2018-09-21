# WebRTC-iOS

## WebRTC Live Streaming

- WebRTC-iOS
- [Android client](https://github.com/balwant108/WebRTC-Android)
- [server](https://github.com/balwant108/WebRTC-Server)

The signaling part is done with [socket.io](socket.io).

## Install

* git clone https://github.com/balwant108/WebRTC-iOS

## WebRTC Live Streaming

An iOS client for [WebRTC-iOS](https://github.com/balwant108/WebRTC-iOS).

It is designed to demonstrate WebRTC video calls between iOS , Android and/or desktop browsers, but WebRtcClient could be used in other scenarios.
You can import the webrtc-client module in your own app if you want to work with it.


## How To

You need [WebRTC-Server](https://github.com/balwant108/WebRTC-Server) up and running, and it must be somewhere that your android can access. (You can quickly test this with your android browser)

When you launch the app, you will be given several options to send a message : "Call someone".
Use this menu to send a link of your stream. This link can be opened with a WebRTC-capable browser or by another WWebRTC-iOS.
The video call should then start.

## Libraries

### [libjingle peerconnection](https://code.google.com/p/webrtc/)

