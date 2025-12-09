import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:zap_scanner/controllers/zap_controller.dart';
import 'package:zap_scanner/models/report.dart';
import 'package:zap_scanner/services/db_service.dart';
import 'package:zap_scanner/services/zap_service.dart';

import '../mocks.mocks.dart';

void main() {
  group('ZapController', () {
    late ZapService mockZapService;
    late DbService mockDbService;
    late ZapController controller;

    setUp(() {
      mockZapService = MockZapService();
      mockDbService = MockDbService();
      Get.put<DbService>(mockDbService);
      
      // Mock the getAllReports method to avoid errors during onInit
      when(mockDbService.getAllReports()).thenReturn(<Report>[]);
      
      controller = ZapController(mockZapService);
    });

    tearDown(() {
      Get.reset();
    });

    test('loadVersion should update version and lastMessage on success', () async {
      const version = '2.11.1';
      when(mockZapService.getVersion()).thenAnswer((_) async => version);

      await controller.loadVersion();

      expect(controller.version, version);
      expect(controller.lastMessage, 'Conectado');
      expect(controller.loading, false);
    });

    test('loadVersion should set version to null and update lastMessage on failure', () async {
      when(mockZapService.getVersion()).thenThrow(Exception('Failed to connect'));

      await controller.loadVersion();

      expect(controller.version, null);
      expect(controller.lastMessage, 'Erro ao conectar: Exception: Failed to connect');
      expect(controller.loading, false);
    });
  });
}
