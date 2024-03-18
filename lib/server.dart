import 'dart:async';
import 'dart:io';

class WebSocketServer {
  HttpServer? _server;
  final _clients = <WebSocket>[];

  Future<void> start() async {
    _server = await HttpServer.bind('192.168.8.112', 8080);
    print('WebSocket Server running on ws://${_server!.address.host}:${_server!.port}');
    _server!.listen((HttpRequest req) async {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        WebSocket socket = await WebSocketTransformer.upgrade(req);
        _clients.add(socket);
        print('New client connected');
        socket.listen((data) {
          // Here, just forward every message to every connected client
          for (var client in _clients) {
            if (client != socket) { // Don't send the message back to the sender
              client.add(data);
            }
          }
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
