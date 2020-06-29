/// A gateway to Google Analytics.
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;

FirebaseAnalytics analytics = FirebaseAnalytics();

logLogin(User user) {
  logger.debug("Login", event: "analytics.setUserId()");
  logger.debug("Login", event: "analytics.logLogin()");
  if (kReleaseMode) return;
  analytics.setUserId(user.id);
  analytics.logLogin();
}

logEvent(String name) {
  logger.debug("Log event $name", event: "analytics.logEvent()");
  if (!kReleaseMode) return;
  analytics.logEvent(name: name);
}

logShare(Sermon sermon) {
  logger.debug("Sermon ${sermon.title} ${sermon.pageUrl}", event: "analytics.logShare()");
  if (!kReleaseMode) return;
  analytics.logShare(contentType: "sermon", itemId: sermon.pageUrl, method: "unknown");
}
