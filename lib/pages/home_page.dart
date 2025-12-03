import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/zap_controller.dart';
import 'report_page.dart';

class HomePage extends GetView<ZapController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final urlCtl = TextEditingController(text: 'example.com');

    return Scaffold(
      appBar: AppBar(title: const Text('ZAP Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: GetBuilder<ZapController>(
            builder: (zap) {
              return Column(
                children: [
                  TextField(
                    controller: urlCtl,
                    decoration: const InputDecoration(
                      labelText: 'URL (ex: example.com ou https://site.com)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: zap.loading ? null : () => zap.loadVersion(),
                        child: const Text('Testar Conexão'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: zap.loading
                            ? null
                            : () => zap.runSpider(urlCtl.text),
                        child: const Text('Rodar Spider'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: zap.loading
                            ? null
                            : () => zap.runActiveScan(urlCtl.text),
                        child: const Text('Rodar Active Scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Versão: ${zap.version ?? '---'}'),
                  const SizedBox(height: 6),
                  Text(zap.lastMessage),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: zap.progress / 100,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: zap.loading
                        ? null
                        : () async {
                            final html = await zap.getReport();
                            Get.to(() => ReportPage(reportHtml: html));
                          },
                    child: const Text('Gerar / Ver Relatório'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
