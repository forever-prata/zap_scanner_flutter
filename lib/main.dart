import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/zap_controller.dart';
import 'services/zap_service.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ZapController(
            ZapService("http://192.168.1.11:8080"),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZAP Scanner',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
