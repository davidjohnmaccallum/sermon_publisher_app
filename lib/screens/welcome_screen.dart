import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sermon_publish/const.dart';
import 'package:sermon_publish/screens/account_disabled_screen.dart';
import 'package:sermon_publish/screens/new_user_screen.dart';
import 'package:sermon_publish/screens/sermon_list_screen.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/auth_service.dart' as authService;
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;

/// A beautiful welcome and authentication screen.
///
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      _buildBackground(),
      Column(children: <Widget>[
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              _buildTitle(),
              _buildSignInButton(context),
              _isLoading ? _buildProgressIndicator() : Container(),
            ])),
        Expanded(child: Container())
      ])
    ]));
  }

  Widget _buildBackground() => Container(
          decoration: BoxDecoration(
              image: DecorationImage(
        image: AssetImage("assets/welcome.jpg"),
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      )));

  Widget _buildTitle() => Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Text("Sermon Publisher",
          key: Key(WelcomeScreenKeys.titleText),
          style: TextStyle(
            fontSize: 30.0,
            fontFamily: "Lora",
          )));

  Widget _buildSignInButton(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          key: Key(WelcomeScreenKeys.signInButton),
          child: SignInButton(
            Buttons.Google,
            onPressed: () => _onSignInWithGooglePressed(context),
          ),
        ),
      );

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: CircularProgressIndicator(),
      );

  void _onSignInWithGooglePressed(BuildContext context) async {
    try {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });

      authService.AuthResult authResult = await authService.googleAuth();

      analyticsService.logLogin(authResult.user);

      if (authResult.isNewUser) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewUserScreen()));
      } else if (authResult.user.enabled) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SermonListScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountDisabledScreen()));
      }
    } catch (err, stack) {
      logger.error("Welcome page, signin error", event: "", err: err, stack: stack);
      showError(context, "Welcome page, signin error", err: err, stack: stack);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
