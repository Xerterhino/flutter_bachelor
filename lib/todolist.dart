import 'package:flutter/material.dart';
import 'package:flutterbachelor/activity.dart';
import 'package:flutterbachelor/timer_page.dart';
import 'package:background_fetch/background_fetch.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

class AcitivityListView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _AcitivityListViewState();
  }

  List<Activity> activities;

}

class _AcitivityListViewState extends State<AcitivityListView> {
  final List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    getActivites();

  }

  void getActivites() async {
    final http.Response response = await http.get('http://192.168.178.44:8080/api/activity');
    if (response.statusCode == 200) {
      final List responseData = json.decode(response.body);
      activities.clear();
      responseData.forEach((act) {
        final Activity newAct = Activity(
            name: act["name"],
            duration: act["duration"],
            finished: false,
            id: act["_id"]
        );
        setState(() {
          activities.add(newAct);
        });

      });
    } else {

      throw Exception('Failed to load Activity ' + response.statusCode.toString() + json.decode(response.body).toString());
    }
  }

  Text getDurationFromMs(String input) {
  /*  Duration tmp = new Duration(milliseconds: int.parse(ms));
    int seconds = tmp.inSeconds;
    int minutes = (seconds/60).floor();
    int displaySeconds = seconds%60;
*/


    double s = double.parse(input);
    double ms = s % 1000;
    s = (s - ms) / 1000;
    double secs = s % 60;
    s = (s - secs) / 60;
    double mins = s % 60;
    double hrs = (s - mins) / 60;
    return Text(mins.round().toString() + ':' + secs.round().toString() + '.' + ms.round().toString());
    //return Text(minutes.toString() + ":" + displaySeconds.toString());
  }

  void deleteActivity(String activityId) async{
    final http.Response response = await http.delete('http://192.168.178.44:8080/api/activity/' + activityId);
    if (response.statusCode == 200) {
//      final List responseData = json.decode(response.body);
      getActivites();
    } else {
      throw Exception('Failed to load Activity');
    }
  }
  void createActivity(String name) async {
    final http.Response response = await http.post('http://192.168.178.44:8080/api/activity/',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'duration': '0',
      'finished': 'false'
    }));
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      Navigator.pushNamed(context, "/timer", arguments: ScreenArguments(responseData["_id"], responseData["name"], responseData["duration"] ));
    } else {
      throw Exception('Failed to load Activity');
    }
  }

  void schedulePushTaskPeriodic() {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.background.fetchFlutter",
      delay: 30000,  // <-- milliseconds
      periodic: true,
      enableHeadless: true,

    ));
  }

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO app'),
      ),
      body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.access_alarm,
                        size: 20.0,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, size: 24.0, color: Colors.red, semanticLabel: 'Delete activity'),
                        onPressed: () => deleteActivity(activities[index].getId())  ,
                      ),
                      title: Text(activities[index].getName()),
                      subtitle: getDurationFromMs(activities[index].getDuration()),
                      onTap: () => Navigator.pushNamed(context, "/timer", arguments: ScreenArguments(activities[index].getId(), activities[index].getName(), activities[index].getDuration() )),
                    );
                  }) ,
            ),
//            Expanded(child: Container()),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                // Opens the keyboard automatically
//                autofocus: true,
                  controller: controller,
                  decoration: InputDecoration(
                      labelText: 'Enter name for your activtiy'
                  )
              )

            )]      ),
      // Add a button to open the screen to create a new task
      floatingActionButton: FloatingActionButton(
//          onPressed: () => Navigator.pushNamed(context, '/create'),
          onPressed: () => createActivity(controller.text),
          child: Icon(Icons.add)
      ),
    );
  }
}