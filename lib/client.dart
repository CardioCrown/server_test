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
    _channel = IOWebSocketChannel.connect('ws://192.168.8.112:8080');
    _channel!.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      _handleSignalingMessage(parsedMessage);
    });
  }

  Future<void> _setupPeerConnection() async {
    final Map<String, dynamic> configuration = {
      "iceServers": [] // Omitting ICE servers
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        _localRenderer.srcObject = event.streams[0];
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _channel!.sink.add(jsonEncode({
        'type': 'candidate',
        'candidate': candidate.toMap(),
      }));
    };
  }

  void _handleSignalingMessage(dynamic message) async {
    // Handling signaling messages...
  }

  void _sendTestMessage() {
    if (_channel != null) {
      _channel!.sink.add('Test');
      print('Test message sent to the server');
    }
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _sendTestMessage,
              child: const Text('Send Test'),
            ),
          ),
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
