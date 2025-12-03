import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/zap_controller.dart';
import 'models/report.dart';
import 'services/db_service.dart';
import 'services/zap_service.dart';
import 'pages/home_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());

  final dbService = DbService();
  await dbService.openBox();
  Get.put(dbService);

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
