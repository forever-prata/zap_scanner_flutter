import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/zap_controller.dart';
import 'services/zap_service.dart';
import 'pages/home_page.dart';

void main() {
  Get.put(ZapController(ZapService("http://172.16.1.58:8080")));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ZAP Scanner',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
