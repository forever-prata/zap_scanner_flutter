import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 0)
class Report extends HiveObject {
  @HiveField(0)
  late String url;

  @HiveField(1)
  late String reportHtml;

  @HiveField(2)
  late DateTime createdAt;
}
