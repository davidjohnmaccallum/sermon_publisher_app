import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/storage_service.dart' as storageService;

/// Publish the sermon to the cloud.
///
class SermonPublishScreen extends StatefulWidget {
  final Sermon sermon;

  SermonPublishScreen(this.sermon, {Key key}) : super(key: key);

  @override
  State<SermonPublishScreen> createState() => _SermonPublishScreenState(sermon);
}

class _SermonPublishScreenState extends State<SermonPublishScreen> {
  double _progressValue = 0;
  bool isUploading = false;
  Sermon sermon;

  _SermonPublishScreenState(this.sermon);

  @override
  initState() {
    super.initState();
    logger.debug("SermonPublish", event: "_SermonPublishState.initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publishing sermon"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "File size: ${sermon.audioFile != null ? filesize(sermon.audioFile.length) : ''}",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(
                value: _progressValue,
              ),
            ),
            RaisedButton(
              onPressed: _startUpload(context),
              child: Text(
                'Start upload',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  _startUpload(BuildContext context) => () async {
        try {
          if (isUploading) return;
          isUploading = true;

          analyticsService.logEvent("upload_sermon");

          setState(() {
            _progressValue = null;
          });

          String url = await storageService.uploadSermon(sermon, _onUploadProgressUpdate, _onUploadError);

          Navigator.pop(context, url);
        } catch (err, stack) {
          logger.error("", event: "", err: err, stack: stack);
          showError(context, "Sermon publish, could not upload", err: err, stack: stack);
        }
      };

  void _onUploadProgressUpdate(StorageTaskEvent event) {
    setState(() {
      _progressValue = event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
    });
  }

  void _onUploadError(Object err) {
    showError(context, "Sermon publish, error uploading", err: err);
  }
}
