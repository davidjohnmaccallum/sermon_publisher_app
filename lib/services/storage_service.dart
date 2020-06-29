// A gateway to Google Cloud Storage.
// ==================================

import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:sermon_publish/const.dart';
import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/registry_service.dart' as registry;
import 'package:sermon_publish/services/logger_service.dart' as logger;

/// Creates a storage bucket in Google Cloud Storage for the user.
createStorageBucket(String bucketName) =>
    mockServices ? _mockCreateStorageBucket(bucketName) : _createStorageBucket(bucketName);

_createStorageBucket(String bucketName) async {
  logger.debug("Creating bucket $bucketName on GCS.", event: "_createStorageBucket()");
  Response response = await get(Uri.encodeFull("https://sermon-publish-api.herokuapp.com/createBucket/$bucketName"));
  if (response.statusCode > 299) throw ("Error creating bucket. ${response.statusCode} ${response.body}");
}

_mockCreateStorageBucket(String bucketName) async {
  logger.debug("Mock function.", event: "_mockCreateStorageBucket()");
}

/// Uploads the sermon audio file to the user's storage bucket.
Future<String> uploadSermon(
        Sermon sermon, void Function(StorageTaskEvent) onProgressUpdate, void Function(Error) onError) =>
    mockServices
        ? _mockUploadSermon(sermon, onProgressUpdate, onError)
        : _uploadSermon(sermon, onProgressUpdate, onError);

Future<String> _uploadSermon(
    Sermon sermon, void Function(StorageTaskEvent) onProgressUpdate, void Function(Object) onError) async {
  User user = registry.getUser();
  File file = File(sermon.audioFile.path);

  logger.info("Uploading sermon ${sermon.title}",
      event: "_uploadSermon()", details: {"title": sermon.title, "filePath": file.path, "fileSize": file.lengthSync()});

  final StorageReference storageReference =
      FirebaseStorage(storageBucket: "gs://${user.bucketName}").ref().child("/sermons/${sermon.id}");
  var data = await file.readAsBytes();
  var uploadTask = storageReference.putData(data);

  final StreamSubscription<StorageTaskEvent> streamSubscription =
      uploadTask.events.listen(onProgressUpdate, onError: onError);

  // Cancel your subscription when done.
  await uploadTask.onComplete;
  streamSubscription.cancel();

  return await storageReference.getDownloadURL() as String;
}

Future<String> _mockUploadSermon(
    Sermon sermon, void Function(StorageTaskEvent) onProgressUpdate, void Function(Error) onError) async {
  logger.debug("Mock function.", event: "_mockUploadSermon()");
  return "http://todo";
}

/// Deletes the sermon audio file fromt the user's storage bucket.
deleteSermon(Sermon sermon) => mockServices ? _mockDeleteSermon(sermon) : _deleteSermon(sermon);

_deleteSermon(Sermon sermon) async {
  logger.debug("Deleting sermon ${sermon.title}.", event: "_deleteSermon()");
  User user = registry.getUser();
  await FirebaseStorage(storageBucket: "gs://${user.bucketName}").ref().child("/sermons/${sermon.id}").delete();
}

_mockDeleteSermon(Sermon sermon) async {
  logger.debug("Mock function.", event: "_mockDeleteSermon()");
}
