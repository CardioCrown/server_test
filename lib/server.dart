import 'dart:async';
import 'dart:io';

class WebSocketServer {
  HttpServer? _server;
  final _clients = <WebSocket>[];

  Future<void> start() async {
    // Bind the server to the specified IP address and port
    _server = await HttpServer.bind('192.168.8.112', 8080);
    _server!.listen((HttpRequest req) async {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        WebSocket socket = await WebSocketTransformer.upgrade(req);
        _clients.add(socket);
        socket.listen((data) {
          print('Data received: $data'); // Print the received data
          for (var client in _clients) {
            client.add(data); // Broadcast the data to all clients
          }
        }, onDone: () {
          _clients.remove(socket);
        });
      }
    });
    print('WebSocket Server running on ws://${_server!.address.host}:${_server!.port}');
  }
}
