import 'package:flutter/material.dart';
import 'client.dart'; // Make sure this path is correct
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
    return MaterialApp(
      home: WebRTCViewer(), // Ensure this class is correctly defined in client.dart
      debugShowCheckedModeBanner: false,
    );
  }
}
