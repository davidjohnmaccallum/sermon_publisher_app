import 'package:flutter/material.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/screens/sermon_list_screen.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;

/// Capture information from the user to setup his/her account.
///
class NewUserScreen extends StatefulWidget {
  @override
  _NewUserScreenState createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  User user;

  @override
  void initState() {
    super.initState();
    user = registry.getUser();
    logger.debug("New user ${user.name}", event: "_NewUserFormState.initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: <Widget>[
                      Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        _buildTitle(),
                        _buildMinistryNameField(),
                        _buildSaveButton(),
                        _isLoading ? _buildProgressIndicator() : Container(),
                      ])
                    ])))));
  }

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Initial setup",
          style: TextStyle(
            fontSize: 30.0,
            fontFamily: "Lora",
          ),
        ),
      );

  Widget _buildMinistryNameField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
          initialValue: user.ministryName,
          decoration: InputDecoration(labelText: "Your ministry name", border: OutlineInputBorder()),
          onChanged: (value) {
            user.ministryName = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter a ministry name.";
            }
            return null;
          },
        ),
      );

  Widget _buildSaveButton() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        onPressed: _onSavePressed(context),
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
        color: Theme.of(context).primaryColor,
      ));

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: CircularProgressIndicator(),
      );

  Function _onSavePressed(BuildContext context) => () async {
        try {
          if (_isLoading) return;
          setState(() {
            _isLoading = true;
          });

          if (_formKey.currentState.validate()) {
            await user.save();
            analyticsService.logEvent("new_user_form_save");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SermonListScreen()));
          } else {
            // Form is invalid
            analyticsService.logEvent("new_user_form_invalid");
            setState(() {
              _isLoading = false;
            });
          }
        } catch (err, stack) {
          logger.error("New user form, error updating profile", event: "", err: err, stack: stack);
          setState(() {
            _isLoading = false;
          });
          showError(context, "New user form, error updating profile", err: err, stack: stack);
        }
      };
}
