// A logger that logs to the DB.
// =============================

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

import '../const.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

String _deviceId;

init() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _deviceId = androidInfo.androidId;
    debug("${androidInfo.manufacturer} model:${androidInfo.model} ver:${androidInfo.version}", event: "device_info");
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    _deviceId = iosInfo.identifierForVendor;
    debug("${iosInfo.name} model:${iosInfo.model} ver:${iosInfo.systemVersion}", event: "device_info");
  }
}

debug(String message, {String event, Object details}) {
  if (LogLevel.debug.index >= logLevel.index) _log('DEBUG', message, event: event, details: details);
}

info(String message, {String event, Object details}) {
  if (LogLevel.info.index >= logLevel.index) _log('INFO', message, event: event, details: details);
}

error(String message, {String event, Object err, StackTrace stack}) {
  String details = [err, stack].where((it) => it != null).map((it) => it.toString()).join("\n");
  if (LogLevel.error.index >= logLevel.index) _log('ERROR', message, event: event, details: details);
}

_log(String level, String message, {String event, Object details}) {
  print("$level: $event: $message");
  if (details != null) {
    print(details);
  }
  if (!kReleaseMode) return;
  Firestore.instance.collection('/logs').document().setData({
    'androidId': _deviceId,
    'level': level,
    'event': event,
    'message': message,
    'details': details != null ? details.toString() : null,
    'timestamp': Timestamp.now()
  });
}
