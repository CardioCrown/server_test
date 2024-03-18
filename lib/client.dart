import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketClient extends StatefulWidget {
  @override
  _WebSocketClientState createState() => _WebSocketClientState();
}

class _WebSocketClientState extends State<WebSocketClient> {
  IOWebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    _channel = IOWebSocketChannel.connect('ws://127.0.0.1:8080');
    _channel!.stream.listen((message) {
      print(message);
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
        title: Text('WebSocket Client'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Send Test'),
          onPressed: () {
            _channel?.sink.add('Test');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
