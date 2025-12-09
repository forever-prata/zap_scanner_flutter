import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zap_scanner/controllers/zap_controller.dart';
import 'package:zap_scanner/pages/home_page.dart';
import 'package:zap_scanner/pages/reports_list_page.dart';
import 'package:zap_scanner/services/db_service.dart';
import 'package:zap_scanner/services/zap_service.dart';

import '../mocks.mocks.dart';

void main() {
  group('HomePage', () {
    late ZapService mockZapService;
    late DbService mockDbService;

    setUp(() {
      mockZapService = MockZapService();
      mockDbService = MockDbService();
      Get.put<DbService>(mockDbService);
      Get.put<ZapController>(ZapController(mockZapService));
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should render HomePage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ZAP Scanner'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Column), findsWidgets); // Expect multiple Columns due to internal structure
      expect(find.byIcon(Icons.power), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('tapping history button navigates to ReportsListPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const HomePage(),
          getPages: [
            GetPage(name: '/reports', page: () => const ReportsListPage()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(ReportsListPage), findsOneWidget);
    });
  });
}
