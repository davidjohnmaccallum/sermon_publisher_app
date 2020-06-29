import 'package:flutter/material.dart';
import 'package:share/share.dart';

/// Display error information to the user and allow the user to report the error.
///
Future<void> showError(BuildContext context, String shortMessage, {Object err, StackTrace stack}) => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error happened"),
        content: Text(err.toString()),
        actions: <Widget>[
          FlatButton(
            child: Text("Tell David"),
            onPressed: () {
              String text = [shortMessage, err, stack].where((it) => it != null).map((it) => it.toString()).join("\n");
              Share.share(text, subject: shortMessage);
            },
          ),
          FlatButton(
            child: Text("Dismiss"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
