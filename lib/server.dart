import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebSocketServer {
  HttpServer? _server;
  final _clients = <WebSocket>[];

  void broadcast(String message, WebSocket from) {
    for (final client in _clients) {
      if (client != from) {
        client.add(message);
      }
    }
  }

  Future<void> start() async {
    _server = await HttpServer.bind('192.168.8.112', 8080);
    print('WebSocket Server running on ws://${_server!.address.host}:${_server!.port}');
    _server!.listen((HttpRequest req) async {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        WebSocket socket = await WebSocketTransformer.upgrade(req);
        _clients.add(socket);
        print('New client connected');
        socket.listen((data) {
          print('Data received: $data');
          // Broadcast the received message to all other connected clients
          broadcast(data, socket);
        }, onDone: () {
          _clients.remove(socket);
          print('Client disconnected');
        });
      }
    });
  }
}

void main() {
  WebSocketServer server = WebSocketServer();
  server.start();
}
