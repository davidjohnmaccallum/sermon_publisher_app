import 'package:flutter/material.dart';
import 'package:sermon_publish/model/user.dart';
import 'package:sermon_publish/screens/sermon_list_screen.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/registry_service.dart' as registry;

/// Capture information from the user to setup his/her account.
///
class ProfileUpdateScreen extends StatefulWidget {
  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  User user;

  @override
  void initState() {
    super.initState();
    user = registry.getUser();
    logger.debug("User ${user?.name}", event: "_ProfileUpdateScreenState.initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: _isLoading
                ? _buildProgressIndicator()
                : SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: <Widget>[
                              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                _buildTitle(),
                                _buildPicture(),
                                _buildMinistryNameField(),
                                _buildEmailField(),
                                _buildPhoneNumberField(),
                                _buildEmailContactSwitch(),
                                _buildPhoneContactSwitch(),
                                _buildSaveButton(),
                              ])
                            ]))),
                  )));
  }

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "My profile",
          style: TextStyle(
            fontSize: 30.0,
            fontFamily: "Lora",
          ),
        ),
      );

  Widget _buildPicture() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            user.changePhoto();
          },
          child: Column(
            children: <Widget>[
              Image.network(user.photoUrl),
              Text('Tap to edit'),
            ],
          ),
        ),
      );

  Widget _buildMinistryNameField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: user.ministryName,
          decoration: InputDecoration(labelText: "Your ministry name", border: UnderlineInputBorder()),
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

  Widget _buildEmailField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: user.email,
          decoration: InputDecoration(labelText: "Your email address", border: UnderlineInputBorder()),
          onChanged: (value) {
            user.email = value;
          },
          validator: (value) {
            if (user.emailContactEnabled && value.isEmpty) {
              return "Please enter an email address.";
            }
            return null;
          },
        ),
      );

  Widget _buildPhoneNumberField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: user.phoneNumber,
          decoration: InputDecoration(labelText: "Your phone number", border: UnderlineInputBorder()),
          onChanged: (value) {
            user.phoneNumber = value;
          },
          validator: (value) {
            if (user.phoneContactEnabled && value.isEmpty) {
              return "Please enter a phone number.";
            }
            return null;
          },
        ),
      );

  Widget _buildEmailContactSwitch() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Allow listeners to contact you via email'),
            Switch(
              value: user.emailContactEnabled,
              onChanged: (value) {
                setState(() {
                  user.emailContactEnabled = value;
                });
              },
            ),
          ],
        ),
      );

  Widget _buildPhoneContactSwitch() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Allow listeners to contact you via phone'),
            Switch(
              value: user.phoneContactEnabled,
              onChanged: (value) {
                setState(() {
                  user.phoneContactEnabled = value;
                });
              },
            ),
          ],
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

  Widget _buildProgressIndicator() => Center(
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
