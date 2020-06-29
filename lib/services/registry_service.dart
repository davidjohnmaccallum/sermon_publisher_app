// A reigstry to provide easy access to data and
// avoid repeated calls the the DB.
// =============================================

import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;

/// Store the user pricipal in the registry.
setUser(User user) {
  logger.debug("Setting user $user", event: "registry.setUser()");
  _user = user;
}

/// Get the user principal from the registry.
User getUser() {
  logger.debug("Getting user $_user", event: "registry.getUser()");
  return _user;
}

/// Store the user's sermon list in the registry.
setSermons(List<Sermon> sermons) {
  logger.debug("Setting sermons ${sermons.map((sermon) => sermon.title).join("\n")}", event: "registry.setSermons()");
  _sermons = sermons;
}

/// Get the user's sermon list from the registry.
List<Sermon> getSermons() {
  logger.debug("Getting sermons ${_sermons?.map((sermon) => sermon.title)?.join("\n")}",
      event: "registry.getSermons()");
  return _sermons;
}

User _user;
List<Sermon> _sermons;
