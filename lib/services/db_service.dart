import 'package:hive/hive.dart';
import 'package:zap_scanner/models/report.dart';

class DbService {
  static const _reportsBoxName = 'reports';

  Future<void> openBox() async {
    await Hive.openBox<Report>(_reportsBoxName);
  }

  Future<void> saveReport(Report report) async {
    final box = Hive.box<Report>(_reportsBoxName);
    await box.add(report);
  }

  List<Report> getAllReports() {
    final box = Hive.box<Report>(_reportsBoxName);
    return box.values.toList();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
