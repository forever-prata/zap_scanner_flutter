import 'dart:async';
import 'package:get/get.dart';
import '../models/report.dart';
import '../services/db_service.dart';
import '../services/zap_service.dart';

class ZapController extends GetxController {
  final ZapService service;
  final DbService dbService = Get.find<DbService>();

  ZapController(this.service);

  String? version;
  bool loading = false;
  int progress = 0;
  String lastMessage = '';
  Timer? _pollTimer;

  var reports = <Report>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAllReports();
  }

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
      update();
    }
  }

  Future<String?> runSpider(String url) async {
    loading = true;
    progress = 0;
    update();
    try {
      await service.newSession();
      final scanId = await service.startSpider(url);
      lastMessage = 'Spider iniciado: id=$scanId';
      await _pollStatus(scanId!, isSpider: true);
      return scanId;
    } catch (e) {
      lastMessage = 'Erro spider: $e';
      rethrow;
    } finally {
      loading = false;
      update();
    }
  }

  Future<String?> runActiveScan(String url) async {
    loading = true;
    progress = 0;
    update();
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
      update();
    }
  }

  Future<void> _pollStatus(String scanId, {required bool isSpider}) async {
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
          update();
          if (progress >= 100) {
            t.cancel();
            completer.complete();
          }
        }
      } catch (e) {
        lastMessage = 'Erro no polling: $e';
        update();
      }
    });
    return completer.future;
  }

  Future<String> getReport() async {
    return await service.getReportHtml();
  }

  Future<void> saveReport(Report report) async {
    await dbService.saveReport(report);
    getAllReports(); // Refresh the list
    Get.back(); // Go back from report page after saving
    Get.snackbar('Salvo', 'Relatório salvo com sucesso!');
  }

  Future<void> getAllReports() async {
    // Pequeno atraso para permitir que a interface do usuário mostre o indicador de carregamento
    await Future.delayed(const Duration(milliseconds: 1500));
    reports.value = dbService.getAllReports();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    dbService.close();
    super.onClose();
  }
}
