import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zap_scanner/controllers/zap_controller.dart';
import 'package:zap_scanner/models/report.dart';

class ReportPage extends StatefulWidget {
  final Report report;
  const ReportPage({super.key, required this.report});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final WebViewController _ctrl;

  @override
  void initState() {
    super.initState();

    const darkThemeCss = '''
      <style>
        body {
          background-color: #121212 !important;
          color: #E0E0E0 !important;
        }
        h1, h2, h3, h4, h5, h6 {
          color: #FFFFFF !important;
        }
        table, th, td {
          border: 1px solid #444 !important;
          border-collapse: collapse !important;
          color: #E0E0E0 !important;
        }
        th {
          background-color: #333333 !important;
        }
        td {
          background-color: transparent !important;
        }
        tr:nth-child(odd) {
          background-color: #1E1E1E !important;
        }
        tr:nth-child(even) {
          background-color: #242424 !important;
        }
        a {
          color: #BB86FC !important;
        }
      </style>
    ''';

    final htmlWithDarkTheme = widget.report.reportHtml.replaceFirst(
      '</head>',
      '$darkThemeCss</head>',
    );

    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlWithDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatório: ${widget.report.url}')),
      body: WebViewWidget(controller: _ctrl),
      floatingActionButton: widget.report.isInBox
          ? null
          : FloatingActionButton(
              onPressed: () {
                Get.find<ZapController>().saveReport(widget.report);
              },
              child: const Icon(Icons.save),
            ),
    );
  }
}
