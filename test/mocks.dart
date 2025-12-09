import 'package:mockito/annotations.dart';
import 'package:zap_scanner/services/db_service.dart';
import 'package:zap_scanner/services/zap_service.dart';

@GenerateNiceMocks([MockSpec<ZapService>(), MockSpec<DbService>()])
void main() {}
