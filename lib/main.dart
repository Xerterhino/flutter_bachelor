import 'package:flutter/material.dart';
import 'package:flutterbachelor/activity.dart';
import 'package:flutterbachelor/local_notification.dart';
import 'package:flutterbachelor/timer_page.dart';
import 'package:flutterbachelor/todolist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:background_fetch/background_fetch.dart';

const myTask = "syncWithTheBackEnd";

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  schedulePushTaskPeriodic();
  _showNotification();
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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


  if(Platform.isAndroid){
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.background.fetchFlutter",
      delay: 30000,
      periodic: true,
      enableHeadless: true,

    ));
  } else if (Platform.isIOS) {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.background.fetchFlutter",
      delay: 30000,
      periodic: true,
      enableHeadless: true,

    ));
  }


  runApp(
    MaterialApp(
      home: TODOApp(),
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void schedulePushTaskPeriodic() {
  BackgroundFetch.scheduleTask(TaskConfig(
    taskId: "com.background.fetchFlutter",
    delay: 30000,  // <-- milliseconds
    periodic: true,
    enableHeadless: true,

  ));
}

void callbackDispatcher() {
}

Future<void> _showNotification() async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description');
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
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false
    ), (String taskId) async       {
        switch (taskId) {
          case 'com.background.fetchFlutter':
            _showNotification();
            break;
        }
        BackgroundFetch.finish(taskId);
      });


    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
      initialRoute: '/',
      routes: {
        '/': (context) => AcitivityListView(),
        '/timer': (context) => TimerPage(name: "xxx", duration: "111111", id: "xxx1"),
      },
    );
  }
}


