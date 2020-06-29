import 'package:sermon_publish/model/usage_report.dart';
import 'package:http/http.dart' as http;
import 'package:sermon_publish/model/user.dart';
import 'dart:convert';
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;

import '../const.dart';

Future<UsageReport> getUsageReport() => mockServices ? _mockGetUsageReport() : _getUsageReport();

Future<UsageReport> _getUsageReport() async {
  logger.debug("Getting usage from monitoring serivice.", event: "UsageReport._get()");
  User user = registry.getUser();
  http.Response res = await http.get(usageReportEndpoint + user.bucketName);
  if (res.statusCode > 299 || res.headers['content-type'].indexOf('application/json') == -1) {
    throw ("statusCode: ${res.statusCode} body: ${res.body}");
  }
  var data = json.decode(res.body);
  return UsageReport(
    months: data
        .map<MonthReport>(
          (month) => MonthReport(
            name: month['month'],
            dataPretty: month['dataPretty'],
            costZARPretty: month['costZARPretty'],
            days: month['days']
                .map<DayReport>(
                  (day) => DayReport(
                    name: day['day'],
                    dataPretty: day['dataPretty'],
                    costZARPretty: day['costZARPretty'],
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
  );
}

Future<UsageReport> _mockGetUsageReport() async {
  logger.debug("Returning mock usage data.", event: "UsageReport._mockGet()");
  return UsageReport(
    months: [
      MonthReport(
        name: "July",
        dataPretty: "521Mb",
        costZARPretty: "R33.12",
        days: [
          DayReport(
            name: "12/7/2020",
            dataPretty: "5Mb",
            costZARPretty: "R0.12",
          ),
          DayReport(
            name: "11/7/2020",
            dataPretty: "5Mb",
            costZARPretty: "R0.12",
          ),
          DayReport(
            name: "10/7/2020",
            dataPretty: "5Mb",
            costZARPretty: "R0.12",
          ),
        ],
      ),
    ],
  );
}
