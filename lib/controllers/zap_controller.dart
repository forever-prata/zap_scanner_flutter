import 'dart:async';
import 'package:flutter/material.dart';
import '../services/zap_service.dart';

class ZapController extends ChangeNotifier {
  final ZapService service;

  ZapController(this.service);

  String? version;
  bool loading = false;
  int progress = 0;
  String lastMessage = '';
  Timer? _pollTimer;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  Future<void> loadVersion() async {
    _setLoading(true);
    try {
      version = await service.getVersion();
      lastMessage = 'Conectado';
    } catch (e) {
      version = null;
      lastMessage = 'Erro ao conectar: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> runSpider(String url) async {
    _setLoading(true);
    progress = 0;
    notifyListeners();
    try {
      await service.newSession();
      final scanId = await service.startSpider(url);
      lastMessage = 'Spider iniciado: id=$scanId';
      // poll status
      await _pollStatus(scanId!, isSpider: true);
      return scanId;
    } catch (e) {
      lastMessage = 'Erro spider: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> runActiveScan(String url) async {
    _setLoading(true);
    progress = 0;
    notifyListeners();
    try {
      await service.newSession();
      final scanId = await service.startActiveScan(url);
      lastMessage = 'Active scan iniciado: id=$scanId';
      await _pollStatus(scanId!, isSpider: false);
      return scanId;
    } catch (e) {
      lastMessage = 'Erro active scan: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pollStatus(String scanId, {required bool isSpider}) async {
    // cancela timer anterior se existir
    _pollTimer?.cancel();
    final completer = Completer<void>();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      try {
        final s = isSpider
            ? await service.spiderStatus(scanId)
            : await service.activeScanStatus(scanId);
        if (s != null) {
          final val = int.tryParse(s) ?? 0;
          if (val > progress) {
            progress = val;
          }
          lastMessage = 'Progresso: $progress%';
          notifyListeners();
          if (progress >= 100) {
            t.cancel();
            completer.complete();
          }
        }
      } catch (e) {
        // ignora erro temporário, mas anota
        lastMessage = 'Erro no polling: $e';
        notifyListeners();
      }
    });
    return completer.future;
  }

  Future<String> getReport() async {
    return await service.getReportHtml();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
