import 'package:flutter/material.dart';
import 'package:sermon_publish/model/sermon.dart';
import 'package:sermon_publish/screens/sermon_update_screen.dart';
import 'package:sermon_publish/screens/sermon_publish_screen.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/services/analytics_service.dart' as analyticsService;
import 'package:sermon_publish/services/logger_service.dart' as logger;

/// Display details about the sermon to the user and allow the user to publish and share the sermon.
///
class SermonDetailsScreen extends StatefulWidget {
  final Sermon sermon; // = Sermon.sample();
  SermonDetailsScreen(this.sermon, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SermonDetailsScreenState(sermon);
}

class _SermonDetailsScreenState extends State<SermonDetailsScreen> {
  Sermon sermon;

  _SermonDetailsScreenState(this.sermon);

  @override
  void initState() {
    super.initState();
    logger.debug("SermonDetails", event: "_SermonDetailsState.initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sermon details"),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(
        //       Icons.share,
        //       color: Colors.white,
        //     ),
        //   )
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                sermon.title,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Preached on ${sermon.preachedOnPretty}"),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Listened to ${sermon.listens ?? 0} times"),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Bible References",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                sermon.bibleReferences ?? "None",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                sermon.description ?? "None",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                sermon.isPublished ? "Published" : "Not yet published",
                style: TextStyle(fontSize: 20),
              ),
            ),
            sermon.isPublished
                ? RaisedButton(
                    child: Text("View Published Sermon", style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).primaryColor,
                    onPressed: _viewPublishedSermon,
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RaisedButton(
                      child: Text("Publish", style: TextStyle(color: Colors.white)),
                      color: Theme.of(context).primaryColor,
                      onPressed: (sermon.audioFile != null && sermon.audioFile.exists) ? _publish : null,
                    ),
                  ),
            sermon.audioFile != null && sermon.audioFile.exists
                ? RaisedButton(
                    child: Text("Listen", style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).primaryColor,
                    onPressed: _listen,
                  )
                : Container(),
            sermon.isPublished
                ? RaisedButton(
                    child: Text("Share", style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).primaryColor,
                    onPressed: _share,
                  )
                : Container(),
            RaisedButton(
              child: Text("Edit", style: TextStyle(color: Colors.white)),
              color: Theme.of(context).primaryColor,
              onPressed: _edit,
            ),
            RaisedButton(
              child: Text("Delete", style: TextStyle(color: Colors.white)),
              color: Colors.redAccent,
              onPressed: _delete,
            ),
          ],
        ),
      ),
    );
  }

  _publish() async {
    try {
      analyticsService.logEvent("publish_sermon");
      var url = await Navigator.push(
        context,
        MaterialPageRoute<String>(builder: (context) => SermonPublishScreen(sermon)),
      );
      if (url != null) {
        setState(() {
          sermon.url = url;
        });
        await sermon.save();
      }
    } catch (err, stack) {
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon details, error saving URL after publish.", err: err, stack: stack);
    }
  }

  _viewPublishedSermon() async {
    try {
      sermon.viewPublishedSermon();
    } catch (err, stack) {
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon details, error viewing published sermon.", err: err, stack: stack);
    }
  }

  _listen() async {
    try {
      await sermon.listen();
    } catch (err, stack) {
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon details, error listening to sermon.", err: err, stack: stack);
    }
  }

  _share() async {
    try {
      await sermon.share();
    } catch (err, stack) {
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon details, error sharing sermon.", err: err, stack: stack);
    }
  }

  _edit() async {
    analyticsService.logEvent("edit_sermon");
    Sermon updatedSermon = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SermonUpdateScreen.edit(sermon)),
    );
    if (updatedSermon != null) {
      setState(() {
        sermon = updatedSermon;
      });
    }
  }

  _delete() async {
    try {
      analyticsService.logEvent("delete_sermon");
      bool confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Delete ${sermon.title}"),
          actions: <Widget>[
            FlatButton(child: Text("Yes"), onPressed: () => Navigator.pop(context, true)),
            FlatButton(child: Text("No"), onPressed: () => Navigator.pop(context, false)),
          ],
        ),
      );
      if (confirmed) {
        await sermon.delete();
        Navigator.pop(context);
      }
    } catch (err, stack) {
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon details, error deleting sermon.", err: err, stack: stack);
    }
  }
}
