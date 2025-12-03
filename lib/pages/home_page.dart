import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zap_scanner/models/report.dart';
import '../controllers/zap_controller.dart';
import 'report_page.dart';
import 'reports_list_page.dart';

class HomePage extends GetView<ZapController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final urlCtl = TextEditingController(text: 'http://testphp.vulnweb.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZAP Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Relatórios',
            onPressed: () {
              Get.to(() => const ReportsListPage());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: GetBuilder<ZapController>(
          builder: (zap) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUrlCard(context, urlCtl, zap),
                const SizedBox(height: 12),
                _buildActionsCard(context, urlCtl, zap),
                const SizedBox(height: 12),
                _buildStatusCard(context, zap),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.assessment),
                  label: const Text('Gerar / Ver Relatório'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: zap.loading
                      ? null
                      : () async {
                          final html = await zap.getReport();
                          final report = Report()
                            ..url = urlCtl.text
                            ..reportHtml = html
                            ..createdAt = DateTime.now();
                          Get.to(() => ReportPage(report: report));
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUrlCard(
      BuildContext context, TextEditingController urlCtl, ZapController zap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alvo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtl,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
      BuildContext context, TextEditingController urlCtl, ZapController zap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ações', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  onPressed: zap.loading ? null : () => zap.loadVersion(),
                  icon: Icons.power,
                  label: 'Conexão',
                ),
                _actionButton(
                  onPressed:
                      zap.loading ? null : () => zap.runSpider(urlCtl.text),
                  icon: Icons.bug_report,
                  label: 'Spider',
                ),
                _actionButton(
                  onPressed:
                      zap.loading ? null : () => zap.runActiveScan(urlCtl.text),
                  icon: Icons.shield,
                  label: 'Active Scan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        IconButton.filledTonal(
          iconSize: 32,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, ZapController zap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: Text(zap.lastMessage.isEmpty
                  ? 'Aguardando ação...'
                  : zap.lastMessage),
              subtitle: Text('Versão ZAP: ${zap.version ?? 'Não conectado'}'),
            ),
            const SizedBox(height: 8),
            if (zap.loading)
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: zap.progress / 100,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${zap.progress}%',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
