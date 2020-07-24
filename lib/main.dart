import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:sermon_publish/screens/welcome_screen.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;

import 'model/user.dart';

void main() {
  runApp(MyApp());
  // runApp(TestHarness());
  logger.init();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
      title: 'Sermon Publish',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class TestHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulates a login
    User.get("");

    return MaterialApp(
      title: 'Sermon Publish',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: WelcomeScreen(),
      // home: ProfileUpdateScreen(),
      // home: UsageReportScreen(),
      // home: SermonListScreen(),
      // home: SermonForm(),
      // home: SermonDetails(),
      // home: ModalTester(
      //   modal: AudioFilePicker(),
      // ),
      // home: ModalTester(
      //   modal: SermonPublish(Sermon.sample()),
      // ),
    );
  }
}
