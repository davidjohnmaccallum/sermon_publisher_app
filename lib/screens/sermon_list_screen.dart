import 'package:flutter/material.dart';
import 'package:sermon_publish/model/audio_file.dart';
import 'package:sermon_publish/screens/profile_update_screen.dart';
import 'package:sermon_publish/screens/sermon_details_screen.dart';
import 'package:sermon_publish/screens/ui_helper.dart';
import 'package:sermon_publish/screens/usage_report_screen.dart';
import 'package:sermon_publish/services/logger_service.dart' as logger;
import 'package:sermon_publish/services/permissions_service.dart';
import '../const.dart';
import 'audio_file_picker_screen.dart';
import '../model/sermon.dart';
import 'sermon_update_screen.dart';

/// Displays all of the user’s sermons.
///
class SermonListScreen extends StatefulWidget {
  @override
  _SermonListScreenState createState() => _SermonListScreenState();
}

class _SermonListScreenState extends State<SermonListScreen> {
  List<Sermon> _sermons;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    logger.debug("SermonList", event: "_SermonListState.initState()");
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Sermons",
          key: Key(SermonListScreenKeys.titleText),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UsageReportScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileUpdateScreen()));
            },
          ),
          // IconButton(
          //     icon: Icon(Icons.bug_report),
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => LogList()));
          //     })
        ],
      ),
      body: _isLoading ? _buildProgressIndicator() : _buildSermonsList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _fabPressed,
      ),
    );
  }

  Widget _buildProgressIndicator() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildSermonsList() {
    if (_sermons.length > 0) {
      return RefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: _sermons.map(
            (sermon) {
              return Card(
                child: ListTile(
                  title: Text(sermon.title),
                  subtitle: Text("${sermon.preachedOnPretty}\nListened to ${sermon.listens ?? 0} times"),
                  trailing: sermon.isPublished ? Text("Published") : null,
                  onTap: _sermonPressed(sermon),
                ),
              );
            },
          ).toList(),
        ),
        onRefresh: () => _getData(),
      );
    } else {
      return Center(
        child: Text("Add a sermon using the + button below."),
      );
    }
  }

  _getData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Sermon> sermons = await Sermon.list();

      setState(() {
        _sermons = sermons;
        _isLoading = false;
      });
    } catch (err, stack) {
      setState(() {
        _isLoading = false;
      });
      logger.error("", event: "", err: err, stack: stack);
      showError(context, "Sermon list, error getting sermons.", err: err, stack: stack);
    }
  }

  _fabPressed() async {
    bool granted = await requestStoragePermission();
    if (!granted) {
      logger.error("Storage permission not granted.", event: "requestPermissions()");
      return;
    } else {
      logger.debug("Storage permission granted", event: "requestPermissions()");
    }

    AudioFile file = await Navigator.push<AudioFile>(
        context, MaterialPageRoute<AudioFile>(builder: (context) => AudioFilePickerScreen()));
    if (file == null) return;

    // TODO: Is file already linked to sermon?

    Sermon sermon =
        await Navigator.push<Sermon>(context, MaterialPageRoute(builder: (context) => SermonUpdateScreen.add(file)));
    if (sermon == null) return;

    await Navigator.push(context, MaterialPageRoute(builder: (context) => SermonDetailsScreen(sermon)));

    await _getData();
  }

  Function _sermonPressed(Sermon sermon) => () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => SermonDetailsScreen(sermon)));
        await _getData();
      };
}
