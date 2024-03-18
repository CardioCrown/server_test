import 'package:flutter/material.dart';
import 'client.dart';
import 'server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final server = WebSocketServer();
  server.start();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketClient(),
      debugShowCheckedModeBanner: false,
    );
  }
}
