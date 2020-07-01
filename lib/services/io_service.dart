// A gateway to the device filesystem.
// ===================================

import 'dart:io';

import 'package:path/path.dart';
import 'package:sermon_publish/const.dart';
import 'package:sermon_publish/model/audio_file.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;

Future<List<AudioFile>> listAudioFiles(String dirPath) =>
    mockServices ? _mockListAudioFiles(dirPath) : _listAudioFiles(dirPath);

Future<List<AudioFile>> _listAudioFiles(String dirPath) async {
  logger.debug("Returning audio files on device.", event: "listAudioFiles()");
  List<AudioFile> result = await Directory(dirPath)
      .list(recursive: true, followLinks: false)
      .where((entity) => entity is File && _isAudioFile(entity))
      .map((entity) => AudioFile.fromFile(entity as File))
      .toList();
  result.sort((a, b) => b.modified.compareTo(a.modified));
  return result;
}

Future<List<AudioFile>> _mockListAudioFiles(String dirPath) async => [
      AudioFile('/my/mock/recording-1.mp3', DateTime.now(), 12032928, true),
      AudioFile('/my/mock/recording-2.mp3', DateTime.now(), 10092873, true),
      AudioFile('/my/mock/recording-3.mp3', DateTime.now(), 11223029, false),
    ];

bool _isAudioFile(File f) {
  String ext = extension(f.path);
  return _audioFileExts.indexOf(ext) != -1;
}

final List<String> _audioFileExts = ['.mp3', '.m4a'];
