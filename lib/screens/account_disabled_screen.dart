import 'package:flutter/material.dart';

/// Informs the user that his account is disabled.
///
class AccountDisabledScreen extends StatelessWidget {
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
              _buildMessage(),
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
      child: Text("Account Disabled",
          style: TextStyle(
            fontSize: 30.0,
            fontFamily: "Lora",
          )));

  Widget _buildMessage() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Please contact David to ask for your account to be enabled.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Lora",
          )));
}
