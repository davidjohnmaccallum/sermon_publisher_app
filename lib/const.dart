// NB: This file cannot import any flutter dependencies
// becasue it is imported by our tests.

/// Setting mockServices to true will cause services that interact with
/// remote dependencies to return mock values.
const bool mockServices = false;

// Sets the logging level for services/logger.dart.
enum LogLevel { debug, info, error }
const LogLevel logLevel = LogLevel.debug;

// HTTP endpoint for the usage report API.
const String usageReportEndpoint = 'https://sermon-publish-api.herokuapp.com/getUsage/';

class WelcomeScreenKeys {
  static String titleText = "titleText";
  static String signInButton = "signInButton";
}

class SermonListScreenKeys {
  static String titleText = "titleText";
  static String firstListItem = "firstListItem";
  static String floatingActionButton = "floatingActionButton";
  static String usageReportButton = "usageReportButton";
}

class UsageReportScreenKeys {
  static String titleText = "titleText";
  static String currentMonthName = "currentMonthName";
}

class SermonDetailsScreenKeys {
  static String titleText = "titleText";
  static String sermonTitleText = "sermonTitleText";
  static String preachedOnText = "preachedOnText";
  static String listenedToText = "listenedToText";
  static String bibleReferencesText = "bibleReferencesText";
  static String descriptionText = "descriptionText";
  static String viewPublishedSermonButton = "viewPublishedSermonButton";
  static String listenButton = "listenButton";
  static String shareButton = "shareButton";
  static String editButton = "editButton";
  static String deleteButton = "deleteButton";
}

class SermonUpdateScreenKeys {
  static String titleText = "titleText";
  static String sermonTitleField = "sermonTitleField";
  static String sermonDateField = "sermonDateField";
  static String sermonBibleReferenceField = "sermonBibleReferenceField";
  static String sermonDescriptionField = "sermonDescriptionField";
  static String saveButton = "saveButton";
}

class AudioFilePickerScreenKeys {
  static String titleText = "titleText";
  static String firstListItem = "firstListItem";
}
