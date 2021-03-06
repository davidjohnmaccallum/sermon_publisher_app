// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:sermon_publish/services/firestore_service.dart' as firestore;
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/storage_service.dart' as storageService;

/// A user of the system. Typically a pastor who has sermons to share.
///
class User {
  // Fields
  // ======

  String id;
  String name;
  DateTime signedUpOn;
  String email;
  String phoneNumber;
  String ministryName;
  bool emailContactEnabled = false;
  bool phoneContactEnabled = false;
  String photoUrl;
  String bucketName;
  bool enabled = false;

  // Lifecycle methods
  // =================

  /// Creates a new user.
  ///
  /// This saves the user to the DB and creates a storage bucket for the user's sermons.
  static Future<User> signup(
    String id,
    String name,
    String email,
    String ministryName,
    String photoUrl,
  ) async {
    analyticsService.logEvent("signup_new_user");

    User user = User(
      id: id,
      name: name,
      email: email,
      ministryName: ministryName,
      photoUrl: photoUrl,
      bucketName: Uuid().v1(),
      signedUpOn: DateTime.now(),
    );

    await storageService.createStorageBucket(user.bucketName);

    await firestore.saveUser(user);

    return user;
  }

  Future<void> save() => firestore.saveUser(this);

  // Finders
  // =======

  static Future<User> get(String id) => firestore.getUser(id);

  // Methods
  // =======

  /// Opens the published sermon in a web browser.
  Future<void> changePhoto() async {
    analyticsService.logEvent("change_profile_photo");
    await launch('https://myaccount.google.com/personal-info');
  }

  // Technical stuff
  // ===============

  User({
    this.id,
    this.name,
    this.signedUpOn,
    this.email,
    this.phoneNumber,
    this.ministryName,
    this.emailContactEnabled,
    this.phoneContactEnabled,
    this.photoUrl,
    this.bucketName,
    this.enabled,
  });
}
