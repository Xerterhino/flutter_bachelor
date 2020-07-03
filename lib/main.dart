import 'package:flutter/material.dart';
import 'package:flutterbachelor/activity.dart';
import 'package:flutterbachelor/local_notification.dart';
import 'package:flutterbachelor/timer_page.dart';
import 'package:flutterbachelor/todolist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const myTask = "syncWithTheBackEnd";

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });



  Workmanager.initialize(callbackDispatcher);
  Workmanager.registerPeriodicTask(
    "1",
    myTask, //This is the value that will be returned in the callbackDispatcher
    initialDelay: Duration(seconds: 30),
    //android erlaubt nur 15min frequency as default
  );


  runApp(
    MaterialApp(
      home: TODOApp(),
    ),
  );
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    switch (task) {
      case myTask:
        print("this method was called from native! "+ task);
        _showNotification();
        break;
      case Workmanager.iOSBackgroundTask:
        print("iOS background fetch delegate ran " + task);
        _showNotification();
        break;
    }
    //Return true when the task executed successfully or not
    return Future.value(true);
  });
}

Future<void> _showNotification() async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'Check your activities', 'Did you track anything today?', platformChannelSpecifics,
      payload: 'item x');
}



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


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app',
      initialRoute: '/',
      routes: {
        '/': (context) => TODOList(),
        '/timer': (context) => TimerPage(name: "asd", duration: "111111", id: "asd"),
        '/notification': (context) => HomePage(),
      },
    );
  }
}


