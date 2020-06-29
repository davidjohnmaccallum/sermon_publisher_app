import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/usage_report_service.dart' as usageReportService;

/// Provides access to the users usage data.
///
class UsageReport {
  // Fields
  // ======

  List<MonthReport> months;

  // Finders
  // =======

  static Future<UsageReport> get(User user) => usageReportService.getUsageReport();

  // Technical stuff
  // ===============

  UsageReport({this.months});
}

class MonthReport {
  String name;
  String dataPretty;
  String costZARPretty;
  List<DayReport> days;

  MonthReport({this.name, this.dataPretty, this.costZARPretty, this.days});
}

class DayReport {
  String name;
  String dataPretty;
  String costZARPretty;

  DayReport({this.name, this.dataPretty, this.costZARPretty});
}
