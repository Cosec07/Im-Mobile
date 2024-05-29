import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'database_helper.dart'; // Import the database helper
import 'map_screen.dart'; // Import the MapScreen to view session paths

class SessionsScreen extends StatefulWidget {
  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  Future<List<Map<String, dynamic>>> _getSessions() async {
    return await DatabaseHelper().getSessions();
  }

  String getTimeElapsed(int startTime, int endTime) {
    if (startTime == 0 || endTime == 0) return "0 seconds";
    int seconds = (endTime - startTime) ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;
    return "${hours}h ${minutes % 60}m ${seconds % 60}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessions'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSessions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return Center(child: Text('No sessions found.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> session = sessions[index];
              int startTime = session['start_time'];
              int endTime = session['end_time'];

              return ListTile(
                title: Text(
                  "Session from ${DateTime.fromMillisecondsSinceEpoch(startTime)} to ${DateTime.fromMillisecondsSinceEpoch(endTime)}",
                ),
                subtitle: Text(
                  "Duration: ${getTimeElapsed(startTime, endTime)}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(sessionId: session['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
