import 'package:flutter/material.dart';
import 'package:flutterbachelor/activity.dart';
import 'package:flutterbachelor/timer_page.dart';
import 'package:flutterbachelor/todocreate.dart';
import 'package:flutterbachelor/todolist.dart';


void main() => runApp(TODOApp());

class TODOApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TODO();
  }
}

// Here we are defining a StatefulWidget
class TODO extends StatefulWidget {
  // Every stateful widget must override createState
  @override
  State<StatefulWidget> createState() {
    return TODOState();
  }
}

// This is the state for then TODO widget
class TODOState extends State<TODO> {
  List<Activity> futureActivity = [];

  final List<Activity> activities = [
//    Activity('Do homework', '111', false, "asdf"),
//    Activity('Laundry', '111', false, "asdfasdasdasd"),
//    Activity('Finish this tutorial', '111', false, "asdfasd")
  ];

  @override
  void initState() {
    super.initState();
//    this.getActivites();
  }

  // Function that modifies the state when a new task is created
  void onTaskCreated(String name) {
    // All state modifications have to be wrapped in setState
    // This way Flutter knows that something has changed
    setState(() {
//      activities.add(Activity(name, "1111", false, "654321"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app',
      initialRoute: '/',
      routes: {
        '/': (context) => TODOList(),
        '/create': (context) => TODOCreate(onCreate: onTaskCreated,),
        '/timer': (context) => TimerPage(name: "asd", duration: "111111", id: "asd"),
      },
    );
  }
}


