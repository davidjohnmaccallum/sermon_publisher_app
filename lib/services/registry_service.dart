// A reigstry to provide easy access to data and
// avoid repeated calls the the DB.
// =============================================

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

User _user;
