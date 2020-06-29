import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sermon_publish/model/audio_file.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;
import '../model/sermon.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

enum SermonUpdateMode { add, edit }

///Captures details about the sermon from the user.
///
class SermonUpdateScreen extends StatefulWidget {
  final Sermon sermon;
  final SermonUpdateMode mode;

  SermonUpdateScreen.add(AudioFile audioFile, {Key key})
      : mode = SermonUpdateMode.add,
        sermon = Sermon(),
        super(key: key) {
    sermon.title = basenameWithoutExtension(audioFile.path);
    sermon.preachedOn = audioFile.modified;
    sermon.audioFile = audioFile;
  }

  SermonUpdateScreen.edit(this.sermon, {Key key})
      : mode = SermonUpdateMode.edit,
        super(key: key);

  @override
  _SermonUpdateScreenState createState() => _SermonUpdateScreenState();
}

class _SermonUpdateScreenState extends State<SermonUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    logger.debug("SermonForm ${widget.mode}", event: "_SermonUpdateScreenState.initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: widget.mode == SermonUpdateMode.edit ? Text("Edit sermon") : Text("Add sermon")),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  _buildTitleField(),
                  _buildPreachedOnField(),
                  _buildBibleReferencesField(),
                  _buildDescriptionField(),
                  _buildSaveButton(context),
                ],
              ),
            )));
  }

  Widget _buildTitleField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: widget.sermon.title,
          decoration: InputDecoration(labelText: "Title", border: OutlineInputBorder()),
          onChanged: (value) {
            widget.sermon.title = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return "Your sermon needs a title.";
            }
            return null;
          },
        ),
      );

  Widget _buildPreachedOnField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DateTimeField(
          initialValue: widget.sermon.preachedOn,
          decoration: InputDecoration(labelText: "Date", border: OutlineInputBorder()),
          format: DateFormat("EEE d MMM 'at' h a"),
          onChanged: (value) {
            widget.sermon.preachedOn = value;
          },
          validator: (value) {
            if (value == null) {
              return "Your sermon needs a date.";
            }
            return null;
          },
          onShowPicker: (context, currentValue) async {
            final date = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2100));
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.combine(date, time);
            } else {
              return currentValue;
            }
          },
        ),
      );

  Widget _buildBibleReferencesField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: widget.sermon.bibleReferences,
          decoration: InputDecoration(labelText: "Bible references", border: OutlineInputBorder()),
          onChanged: (value) {
            widget.sermon.bibleReferences = value;
          },
        ),
      );

  Widget _buildDescriptionField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: widget.sermon.description,
          decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
          onChanged: (value) {
            widget.sermon.description = value;
          },
          maxLines: 5,
        ),
      );

  Widget _buildSaveButton(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RaisedButton(
          onPressed: _onSavePressed(context),
          child: Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).primaryColor,
        ),
      );

  Function _onSavePressed(BuildContext context) => () async {
        try {
          if (_formKey.currentState.validate()) {
            analyticsService.logEvent("save_sermon");

            await widget.sermon.save();

            Navigator.pop(context, widget.sermon);
          } else {
            analyticsService.logEvent("sermon_form_invalid");
            logger.debug("Save validation failed ${widget.sermon.title}",
                event: "_SermonUpdateScreenState._onSavePressed()");
          }
        } catch (err, stack) {
          logger.error("", event: "", err: err, stack: stack);
          showError(context, "Sermon form, could not save", err: err, stack: stack);
        }
      };
}
