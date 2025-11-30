import 'dart:convert';
import 'package:http/http.dart' as http;

class ZapService {
  final String baseUrl;
  final String apiKey = "12345";

  ZapService(this.baseUrl);

  String _addApiKey(String url) {
    if (url.contains("?")) return "$url&apikey=$apiKey";
    return "$url?apikey=$apiKey";
  }

  Future<String?> getVersion() async {
    final response = await http.get(
      Uri.parse(_addApiKey('$baseUrl/JSON/core/view/version/')),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['version']?.toString();
    }
    return null;
  }

  Future<void> newSession() async {
    final uri = Uri.parse(
      _addApiKey('$baseUrl/JSON/core/action/newSession/'),
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to create a new session: ${response.statusCode}');
    }
  }

  String _fixUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url';
    }
    return url;
  }

  Future<String?> startSpider(String targetUrl) async {
    final fixed = _fixUrl(targetUrl);
    final encoded = Uri.encodeFull(fixed);

    final uri = Uri.parse(
      _addApiKey('$baseUrl/JSON/spider/action/scan/?url=$encoded'),
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['scan']?.toString();
    }
    throw Exception('Start spider failed: ${response.statusCode} ${response.body}');
  }

  Future<String?> spiderStatus(String scanId) async {
    final uri = Uri.parse(
      _addApiKey('$baseUrl/JSON/spider/view/status/?scanId=$scanId'),
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['status']?.toString();
    }
    return null;
  }

  Future<String?> startActiveScan(String targetUrl) async {
    final fixed = _fixUrl(targetUrl);
    final encoded = Uri.encodeFull(fixed);

    final uri = Uri.parse(
      _addApiKey('$baseUrl/JSON/ascan/action/scan/?url=$encoded'),
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['scan']?.toString();
    }
    throw Exception('Start active scan failed: ${response.statusCode} ${response.body}');
  }

  Future<String?> activeScanStatus(String scanId) async {
    final uri = Uri.parse(
      _addApiKey('$baseUrl/JSON/ascan/view/status/?scanId=$scanId'),
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['status']?.toString();
    }
    return null;
  }

  Future<String> getReportHtml() async {
    final uri = Uri.parse(
      _addApiKey('$baseUrl/OTHER/core/other/htmlreport/'),
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) return response.body;
    throw Exception('Get report failed: ${response.statusCode}');
  }
}
