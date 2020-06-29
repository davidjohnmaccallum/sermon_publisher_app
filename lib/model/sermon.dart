import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;
import 'package:sermon_publish/services/firestore_service.dart' as firestore;
import 'package:sermon_publish/services/storage_service.dart' as storageService;
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import 'audio_file.dart';

/// Represents a  sermon and the audio file associated with it.
///
class Sermon {
  // Fields
  // ======

  String id;
  String title;
  DateTime preachedOn;
  String bibleReferences;
  String description;
  String url;
  num listens = 0;
  AudioFile audioFile;

  // Properties
  // ==========

  String get preachedOnPretty => DateFormat("EEE d MMM 'at' h a").format(preachedOn);
  bool get isPublished => url != null;
  String get pageUrl {
    if (isPublished) {
      User user = registry.getUser();
      return "https://sermon-publish.herokuapp.com/${user.id}/sermon/$id";
    } else {
      return null;
    }
  }

  // Lifecycle methods
  // =================

  /// Saves the sermon to the DB.
  ///
  /// Handles both insert and update.
  save() => firestore.saveSermon(this);

  /// Deletes the sermon doc from the DB and the audio file from cloud storage.
  delete() async {
    if (url != null) {
      await storageService.deleteSermon(this);
    }
    await firestore.deleteSermon(this);
  }

  // Finders
  // =======

  /// Get a list of all sermons belonging to the user.
  static Future<List<Sermon>> list() => firestore.listSermons();

  // Methods
  // =======

  /// Opens the published sermon in a web browser.
  Future<void> viewPublishedSermon() async {
    if (!isPublished) return;
    analyticsService.logEvent("view_published_sermon");
    await launch(pageUrl);
  }

  /// Listens to the local sermon audio file.
  Future<void> listen() async {
    if (!audioFile.exists) return;
    analyticsService.logEvent("listen_to_sermon");
    logger.debug("Listen $title", event: "Sermon.listen()");
    await OpenFile.open(audioFile.path);
  }

  /// Opens the share dialog to share the sermon.
  Future<void> share() async {
    analyticsService.logShare(this);
    analyticsService.logEvent("share_sermon");
    logger.debug("Share $title", event: "Sermon.share()");
    await Share.share("$title $pageUrl", subject: title);
  }

  // Technical stuff
  // ===============

  Sermon({
    this.id,
    this.title,
    this.preachedOn,
    this.bibleReferences,
    this.description,
    this.url,
    this.listens,
    this.audioFile,
  });
}
