import 'package:flutter/material.dart';
import 'client.dart';
import 'server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final server = WebSocketServer();
  server.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WebSocketClient(),
      debugShowCheckedModeBanner: false,
    );
  }
}
