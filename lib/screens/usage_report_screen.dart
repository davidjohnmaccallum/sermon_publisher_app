import 'package:flutter/material.dart';
import 'package:sermon_publish/model/usage_report.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;

/// Show the user how much data has been used and the estimated charges for the month.
///
class UsageReportScreen extends StatefulWidget {
  @override
  _UsageReportScreenState createState() => _UsageReportScreenState();
}

class _UsageReportScreenState extends State<UsageReportScreen> {
  UsageReport _usageReport;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User user = registry.getUser();
      UsageReport usageReport = await UsageReport.get(user);

      setState(() {
        _usageReport = usageReport;
        _isLoading = false;
      });
    } catch (err, stack) {
      setState(() {
        _isLoading = false;
      });
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Usage report, error loading data.", err: err, stack: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Report'),
      ),
      body: _isLoading ? _buildProgressIndicator() : _buildReport(),
    );
  }

  Widget _buildProgressIndicator() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildReport() => RefreshIndicator(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: _usageReport != null ? _usageReport.months.map<Widget>(_buildMonth).toList() : []),
          ),
        ),
        onRefresh: () => _getData(),
      );

  Widget _buildMonth(MonthReport month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: <Widget>[
          _buildMonthSummary(month),
          Column(children: month.days.map<Widget>(_buildDay).toList()),
        ],
      ),
    );
  }

  Widget _buildDay(DayReport day) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            day.name,
            style: TextStyle(fontSize: 25),
          ),
          Text(
            "${day.costZARPretty} (${day.dataPretty})",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(MonthReport month) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          month.name,
          style: TextStyle(fontSize: 60),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              month.dataPretty,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              month.costZARPretty,
              style: TextStyle(fontSize: 40),
            ),
          ],
        ),
      ],
    );
  }
}
