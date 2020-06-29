import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sermon_publish/screens/log_details_screen.dart';

class LogListScreen extends StatefulWidget {
  @override
  _LogListScreenState createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  List<String> androidIds = [];
  Stream<QuerySnapshot> logStream =
      Firestore.instance.collection("/logs").orderBy("timestamp", descending: true).limit(500).snapshots();

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("/logs")
        .orderBy("timestamp", descending: true)
        .limit(500)
        .getDocuments()
        .then((snapshot) {
      List<Map<String, dynamic>> logs = snapshot.documents.map((doc) => doc.data).toList();

      logs.forEach((log) {
        if (log['androidId'] == null) return;
        if (androidIds.contains(log['androidId'])) return;
        setState(() {
          androidIds.add(log['androidId']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log"),
        actions: [
          DropdownButton(
            items: androidIds.map((androidId) {
              return DropdownMenuItem(
                child: Text(androidId),
                value: androidId,
              );
            }).toList(),
            hint: Text(
              "Filter",
              style: TextStyle(color: Colors.white),
            ),
            onChanged: (androidId) {
              setState(() {
                logStream = Firestore.instance
                    .collection("/logs")
                    .where("androidId", isEqualTo: androidId)
                    .orderBy("timestamp", descending: true)
                    .limit(500)
                    .snapshots();
              });
            },
          ),
        ],
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: logStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Center(child: Text('Error: $snapshot.error'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return new Center(child: Text('Loading...'));
          } else {
            List<Map<String, dynamic>> logs = snapshot.data.documents.map((doc) => doc.data).toList();

            if (logs.length > 0) {
              return ListView(
                children: logs.map((log) {
                  return ListTile(
                    title: Text(log['message']),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(log["event"]),
                        Text(DateFormat("EEE dd/MM H:m:s").format(log['timestamp'].toDate())),
                      ],
                    ),
                    leading: Icon(Icons.trip_origin, color: getIconColor(log['level'])),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LogDetailsScreen(log)));
                    },
                  );
                }).toList(),
              );
            } else {
              return Center(
                child: Text("No logs"),
              );
            }
          }
        });
  }

  Color getIconColor(String level) {
    const colors = {'DEBUG': Colors.blueGrey, 'INFO': Colors.blueAccent, 'ERROR': Colors.redAccent};
    return colors[level] ?? Colors.blueGrey;
  }
}
