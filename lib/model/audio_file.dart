import 'dart:io';

/// The sermon audio file.
///
class AudioFile {
  // Fields
  // ======

  final String path;
  final DateTime modified;
  final int length;
  final bool exists;

  // Constructors
  // ============

  AudioFile(this.path, this.modified, this.length, this.exists);

  AudioFile.fromFile(File file)
      : path = file.path,
        modified = file.existsSync() ? file.lastModifiedSync() : null,
        length = file.existsSync() ? file.lengthSync() : 0,
        exists = file.existsSync();
}
