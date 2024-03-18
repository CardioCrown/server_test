import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebSocketClient extends StatefulWidget {
  const WebSocketClient({super.key});

  @override
  _WebSocketClientState createState() => _WebSocketClientState();
}

class _WebSocketClientState extends State<WebSocketClient> {
  IOWebSocketChannel? _channel;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initRenderer();
    _connectToServer();
  }

  Future<void> initRenderer() async {
    await _localRenderer.initialize();
  }

  void _connectToServer() {
    _channel = IOWebSocketChannel.connect('ws://192.168.8.112:8080');
    _channel!.stream.listen((message) {
      print(message);
      // Here you would handle received signaling messages (SDP, ICE candidates)
      // and use them to establish a peer connection.
    }, onDone: () {
      print("WebSocket Disconnected");
    }, onError: (error) {
      print("WebSocket Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Client'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer), // Placeholder for the video stream
          ),
          ElevatedButton(
            child: const Text('Send Test'),
            onPressed: () {
              _channel?.sink.add('Test');
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _localRenderer.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(home: WebSocketClient()));
}
