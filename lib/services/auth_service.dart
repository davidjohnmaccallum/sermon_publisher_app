// A gateway to Firebase Auth.
// ===========================

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sermon_publish/const.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;

class AuthResult {
  final User user;
  final bool isNewUser;
  AuthResult(this.user, this.isNewUser);
}

/// Authenticate the user using Google Auth.
Future<AuthResult> googleAuth() => mockServices ? _mockGoogleAuth() : _googleAuth();

Future<AuthResult> _googleAuth() async {
  logger.debug("Authenticating using Google.", event: "_googleAuth()");
  // TODO: BUG: If the user cancells the login on iOS an exception is thrown but the catch and finally blocks are not triggered.
  GoogleSignInAccount googleAccount = await GoogleSignIn().signIn();
  GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
  firebaseAuth.AuthResult authResult =
      await firebaseAuth.FirebaseAuth.instance.signInWithCredential(firebaseAuth.GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  ));
  firebaseAuth.FirebaseUser firebaseUser = authResult.user;

  User user = await User.get(firebaseUser.uid);

  if (user == null) {
    user = await User.signup(firebaseUser.uid, firebaseUser.displayName, firebaseUser.email, firebaseUser.displayName);
    return AuthResult(user, true);
  } else {
    return AuthResult(user, false);
  }
}

Future<AuthResult> _mockGoogleAuth() async {
  logger.debug("Doing a mock auth.", event: "_mockGoogleAuth()");
  return AuthResult(await User.get(""), false);
}
