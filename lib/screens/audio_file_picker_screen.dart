import 'package:flutter/material.dart';
import 'package:sermon_publish/model/audio_file.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/io_service.dart' as ioService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:timeago/timeago.dart' as timeago;
import 'package:path/path.dart' as path;

/// Displays a list of audio files on the device and allows the user to choose one.
///
class AudioFilePickerScreen extends StatefulWidget {
  final String dirPath = '/storage/emulated/0';
  AudioFilePickerScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AudioFilePickerScreenState();
}

class _AudioFilePickerScreenState extends State<AudioFilePickerScreen> {
  List<AudioFile> _files;
  bool _isLoading = false;

  initState() {
    super.initState();
    logger.debug("AudioFilePicker", event: "_AudioFilePickerState.initState()");
    _getFiles();
  }

  _getFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<AudioFile> files = await ioService.listAudioFiles(widget.dirPath);

      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (err, stack) {
      logger.error("Error listing files", event: "_AudioFilePickerScreenState.initState()", err: err, stack: stack);
      showError(context, "Error listing files", err: err, stack: stack);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("File picker")), body: getBody());
  }

  Widget getBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_files == null || _files.length == 0) {
      return Center(
        child: Text("No files"),
      );
    } else {
      return ListView(
        children: _files.map(
          (file) {
            return ListTile(
              title: Text(path.basename(file.path)),
              subtitle: Text(
                "Recorded " + timeago.format(file.modified),
              ),
              onTap: () {
                analyticsService.logEvent("pick_file");
                Navigator.pop(context, file);
              },
            );
          },
        ).toList(),
      );
    }
  }
}
