import 'package:flutter/material.dart';
import 'package:flutterbachelor/activity.dart';
import 'package:flutterbachelor/local_notification.dart';
import 'package:flutterbachelor/timer_page.dart';
import 'package:flutterbachelor/todolist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;
import 'package:background_fetch/background_fetch.dart';

const myTask = "syncWithTheBackEnd";

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  _showNotification();
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
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
    Workmanager.initialize(callbackDispatcher);
    Workmanager.registerPeriodicTask(
      "1",
      myTask, //This is the value that will be returned in the callbackDispatcher
      initialDelay: Duration(seconds: 30),
      //android erlaubt nur 15min frequency as default
    );
  } else if (Platform.isIOS) {
    print("IOS");
    //_showNotification();
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: 'com.transistorsoft.fetch',
        delay: 60 * 60 * 1000  //  In one hour (milliseconds)
    ));
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.fetch",
        delay: 5000,  // <-- milliseconds
        periodic: true,

    ));

  }

  runApp(
    MaterialApp(
      home: TODOApp(),
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print("Task" + task);
    switch (task) {
      case myTask:
        print("this method was called from native! "+ task);
        _showNotification();
        break;
      case Workmanager.iOSBackgroundTask:
        print("iOS background fetch delegate ran " + task);
        _showNotification();
        break;
      default:
        print("DEFAULT");
        _showNotification();

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

  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false
    ), (String taskId) async {
print("TASK  ID " + taskId);
      switch (taskId) {
        case 'com.transistorsoft.fetch':
          print("Received custom task");
          _showNotification();
          break;
        default:
          print("Default fetch task");
      }

      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
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


