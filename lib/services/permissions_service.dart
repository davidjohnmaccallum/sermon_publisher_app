import 'package:permission_handler/permission_handler.dart';

import '../const.dart';

/// Prompts the user to provide access to device storage if the user has not already.
Future<bool> requestStoragePermission() => mockServices ? _mockRequestStoragePermission() : _requestStoragePermission();

Future<bool> _requestStoragePermission() => Permission.storage.request().isGranted;

Future<bool> _mockRequestStoragePermission() async => true;
