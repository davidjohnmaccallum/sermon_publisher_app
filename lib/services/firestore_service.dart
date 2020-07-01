import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sermon_publish/model/audio_file.dart';
import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;

import '../const.dart';

// User functions
// ==============

Future<User> getUser(id) => mockServices ? _mockGetUser(id) : _getUser(id);

Future<User> _getUser(id) async {
  // Do we have a local copy?
  User user = registry.getUser();
  if (user != null) {
    logger.debug("Returning user from registry.", event: "_getUser()");
    return user;
  }

  // Get user from DB
  logger.debug("Getting user from Firestore.", event: "_getUser()");
  DocumentReference docRef = Firestore.instance.document("/users/$id");
  DocumentSnapshot doc = await docRef.get();
  if (!doc.exists) return null;

  user = User(
    id: doc.documentID,
    name: doc.data['name'],
    signedUpOn: doc.data['signedUpOn'] != null ? (doc.data['signedUpOn'] as Timestamp).toDate() : null,
    email: doc.data['email'],
    ministryName: doc.data['ministryName'],
    bucketName: doc.data['bucketName'],
    enabled: doc.data['enabled'],
  );

  registry.setUser(user);

  return user;
}

Future<User> _mockGetUser(String id) async {
  User user = registry.getUser();
  if (user != null) {
    logger.debug("Returning user from registry.", event: "_mockGetUser()");
    return user;
  }

  logger.debug("Returning mock user.", event: "_mockGetUser()");
  user = User(
    id: "mock",
    name: "David MacCallum",
    signedUpOn: DateTime.now(),
    email: "davidjohnmac@gmail.com",
    ministryName: "FBC",
    bucketName: "mock.sermon-publish.appspot.com",
    enabled: true,
  );

  registry.setUser(user);

  return user;
}

/// Writes the user to the DB.
///
/// Handles both insert and update.
Future<void> saveUser(User user) async {
  logger.debug("Saving user ${user.name}.", event: "saveUser()");
  DocumentReference docRef;
  if (user.id == null) {
    // This is a new user. Give it an ID.
    docRef = Firestore.instance.collection('users').document();
    user.id = docRef.documentID;

    registry.setUser(user);
  } else {
    docRef = Firestore.instance.document("/users/${user.id}");
  }

  if (mockServices) return;

  // Write data to DB.
  await docRef.setData({
    'name': user.name,
    'signedUpOn': user.signedUpOn != null ? Timestamp.fromDate(user.signedUpOn) : null,
    'email': user.email,
    'ministryName': user.ministryName,
    'bucketName': user.bucketName,
    'enabled': user.enabled,
  });
}

// Sermon functions
// ================

Future<List<Sermon>> listSermons() => mockServices ? _mockListSermons() : _listSermons();

Future<List<Sermon>> _listSermons() async {
  // Read sermons from DB.
  logger.debug("Getting sermons from Firestore.", event: "_listSermons()");
  User user = registry.getUser();
  DocumentReference userRef = Firestore.instance.document("/users/${user.id}");
  QuerySnapshot query = await userRef.collection('sermons').getDocuments();
  List<Sermon> sermons = query.documents
      .map((doc) => Sermon(
          id: doc.documentID,
          audioFile: AudioFile.fromFile(File(doc.data['filePath'])),
          title: doc.data['title'],
          preachedOn: doc.data['preachedOn'] != null ? (doc.data['preachedOn'] as Timestamp).toDate() : null,
          bibleReferences: doc.data['bibleReferences'],
          description: doc.data['description'],
          url: doc.data['url'],
          listens: doc.data['listens'] ?? 0))
      .toList();

  return sermons;
}

Future<List<Sermon>> _mockListSermons() async {
  logger.debug("Returning mock sermons.", event: "_mockListSermons()");
  List<Sermon> sermons = [
    Sermon(
      id: '1',
      title: "The high priestly prayer",
      preachedOn: DateTime.now(),
      bibleReferences: "John 17",
      description:
          "Eu est irure cupidatat elit ut qui tempor cupidatat dolore. Dolor mollit aliqua velit voluptate. Sit ex sunt nulla exercitation ipsum laboris occaecat do id ullamco.",
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      audioFile: AudioFile('/dummy-file.mp3', DateTime.now(), 2928373, true),
      listens: 51,
    ),
    Sermon(
      id: '2',
      title: "Sola fide",
      preachedOn: DateTime.now(),
      bibleReferences: "Romans 5:1",
      description:
          "Eu est irure cupidatat elit ut qui tempor cupidatat dolore. Dolor mollit aliqua velit voluptate. Sit ex sunt nulla exercitation ipsum laboris occaecat do id ullamco.",
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      audioFile: AudioFile('/dummy-file.mp3', DateTime.now(), 2928373, true),
      listens: 521,
    ),
    Sermon(
      id: '3',
      title: "Power to live",
      preachedOn: DateTime.now(),
      bibleReferences: "Romans 8",
      description:
          "Eu est irure cupidatat elit ut qui tempor cupidatat dolore. Dolor mollit aliqua velit voluptate. Sit ex sunt nulla exercitation ipsum laboris occaecat do id ullamco.",
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      audioFile: AudioFile('/dummy-file.mp3', DateTime.now(), 2928373, true),
      listens: 33,
    ),
    Sermon(
      id: '4',
      title: "Reign in life",
      preachedOn: DateTime.now(),
      bibleReferences: "Romans 6",
      description:
          "Eu est irure cupidatat elit ut qui tempor cupidatat dolore. Dolor mollit aliqua velit voluptate. Sit ex sunt nulla exercitation ipsum laboris occaecat do id ullamco.",
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      audioFile: AudioFile('/dummy-file.mp3', DateTime.now(), 2928373, true),
      listens: 15,
    ),
    Sermon(
      id: '5',
      title: "Dying to self",
      preachedOn: DateTime.now(),
      bibleReferences: "Romans 8",
      description:
          "Eu est irure cupidatat elit ut qui tempor cupidatat dolore. Dolor mollit aliqua velit voluptate. Sit ex sunt nulla exercitation ipsum laboris occaecat do id ullamco.",
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      audioFile: AudioFile('/dummy-file.mp3', DateTime.now(), 2928373, true),
      listens: 50,
    ),
  ];

  return sermons;
}

Future<void> saveSermon(Sermon sermon) async {
  logger.debug("Saving user ${sermon.title}.", event: "saveSermon()");
  User user = registry.getUser();
  DocumentReference docRef;
  if (sermon.id == null) {
    // This is a new sermon. Give it an ID.
    docRef = Firestore.instance.collection('/users/${user.id}/sermons').document();
    sermon.id = docRef.documentID;
  } else {
    docRef = Firestore.instance.document("/users/${user.id}/sermons/${sermon.id}");
  }

  if (mockServices) return;

  await docRef.setData({
    'filePath': sermon.audioFile?.path,
    'title': sermon.title,
    'preachedOn': sermon.preachedOn != null ? Timestamp.fromDate(sermon.preachedOn) : null,
    'bibleReferences': sermon.bibleReferences,
    'description': sermon.description,
    'url': sermon.url,
    'listens': sermon.listens,
  });
}

Future<void> deleteSermon(Sermon sermon) async {
  logger.debug("Deleting sermon ${sermon.title}.", event: "deleteSermon()");

  if (mockServices) return;

  User user = registry.getUser();
  DocumentReference docRef = Firestore.instance.document("/users/${user.id}/sermons/${sermon.id}");
  await docRef.delete();
}
