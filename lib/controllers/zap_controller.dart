import 'dart:async';
import 'package:get/get.dart';
import '../services/zap_service.dart';

class ZapController extends GetxController {
  final ZapService service;

  ZapController(this.service);

  String? version;
  bool loading = false;
  int progress = 0;
  String lastMessage = '';
  Timer? _pollTimer;

  // The _setLoading method is removed as 'loading' state changes
  // will trigger updates directly via update()

  Future<void> loadVersion() async {
    loading = true;
    update(); // Notify GetX listeners
    try {
      version = await service.getVersion();
      lastMessage = 'Conectado';
    } catch (e) {
      version = null;
      lastMessage = 'Erro ao conectar: $e';
    } finally {
      loading = false;
      update(); // Notify GetX listeners
    }
  }

  Future<String?> runSpider(String url) async {
    loading = true;
    progress = 0;
    update(); // Notify GetX listeners
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
      loading = false;
      update(); // Notify GetX listeners
    }
  }

  Future<String?> runActiveScan(String url) async {
    loading = true;
    progress = 0;
    update(); // Notify GetX listeners
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
      loading = false;
      update(); // Notify GetX listeners
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
          update(); // Notify GetX listeners
          if (progress >= 100) {
            t.cancel();
            completer.complete();
          }
        }
      } catch (e) {
        // ignora erro temporário, mas anota
        lastMessage = 'Erro no polling: $e';
        update(); // Notify GetX listeners
      }
    });
    return completer.future;
  }

  Future<String> getReport() async {
    return await service.getReportHtml();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}
