import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

class WebRTCViewer extends StatefulWidget {
  const WebRTCViewer({Key? key}) : super(key: key);

  @override
  _WebRTCViewerState createState() => _WebRTCViewerState();
}

class _WebRTCViewerState extends State<WebRTCViewer> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  IOWebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    initRenderer();
    _connectToSignalingServer();
  }

  Future<void> initRenderer() async {
    await _localRenderer.initialize();
    _setupPeerConnection();
  }

  void _connectToSignalingServer() {
    // Connect to your signaling server
    _channel = IOWebSocketChannel.connect('ws://192.168.8.112:8080');
    _channel!.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      _handleSignalingMessage(parsedMessage);
    });
  }

  Future<void> _setupPeerConnection() async {
    final Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        _localRenderer.srcObject = event.streams[0];
      }
    };

    // Handle ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      _channel!.sink.add(jsonEncode({
        'type': 'candidate',
        'candidate': candidate.toMap(),
      }));
    };
  }

  void _handleSignalingMessage(dynamic message) async {
    if (message['type'] == 'offer') {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(message['sdp'], message['type']),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendSignalingMessage({'type': 'answer', 'sdp': answer.sdp});
    } else if (message['type'] == 'candidate') {
      _peerConnection!.addCandidate(
        RTCIceCandidate(
          message['candidate']['candidate'],
          message['candidate']['sdpMid'],
          message['candidate']['sdpMLineIndex'],
        ),
      );
    }
    // Handle other signaling messages as needed
  }

  void _sendSignalingMessage(dynamic message) {
    _channel!.sink.add(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Viewer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer, mirror: true),
          ),
          // You can add more UI components here as needed
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _peerConnection?.close();
    _peerConnection?.dispose();
    _channel?.sink.close();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(home: WebRTCViewer()));
}
