import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zap_scanner/controllers/zap_controller.dart';
import 'package:zap_scanner/pages/report_page.dart';

class ReportsListPage extends GetView<ZapController> {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Salvos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.getAllReports(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.reports.isEmpty) {
          return const Center(child: Text('Nenhum relatório salvo ainda.'));
        }
        
        final sortedReports = controller.reports.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          itemCount: sortedReports.length,
          itemBuilder: (context, index) {
            final report = sortedReports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(report.url),
                subtitle: Text(
                    'Salvo em: ${DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)}'),
                onTap: () {
                  Get.to(() => ReportPage(report: report));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
