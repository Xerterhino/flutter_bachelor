import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class ScreenArguments {
  final name;
  final duration;
  final id;

  ScreenArguments(this.id, this.name, this.duration);
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle =
      const TextStyle(fontSize: 75.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerPage extends StatefulWidget {
  final name;
  final duration;
  final id;

  TimerPage(
      {Key key,
      @required this.name,
      @required this.duration,
      @required this.id})
      : super(key: key);

  TimerPageState createState() => new TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies = new Dependencies();
  bool hasBeenReset = false;

  TimerPageState({
    Key key,
  });

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
      } else {
        dependencies.stopwatch.reset();
        this.hasBeenReset = true;
      }
    });
  }

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
//        this.hasBeenReset = false;
      }
    });
  }

  void saveActivity(String id, String name, String duration) async {
    final http.Response response = await http.put(
        'http://192.168.178.20:8080/api/activity/' + id,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'duration': duration,
          'finished': 'false'
        }));
    if (response.statusCode == 200) {
      Navigator.pushNamed(context, "/");
    } else {
      throw Exception('Failed to update Activity');
    }
  }

  Widget buildFloatingButton(String text, VoidCallback callback) {
    TextStyle roundTextStyle =
        const TextStyle(fontSize: 16.0, color: Colors.white);
    return new FloatingActionButton(
        heroTag: text,
        child: new Text(text, style: roundTextStyle),
        onPressed: callback);
  }

  String getActualTimeElapsed(String elapsedArgTime) {
    if (hasBeenReset) {
      return dependencies.stopwatch.elapsedMilliseconds.toString();
    } else
      return (dependencies.stopwatch.elapsedMilliseconds +
              int.parse(elapsedArgTime))
          .toString();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    final TextEditingController controller =
        TextEditingController(text: args.name);

    final calcDuration = hasBeenReset ? '0' : args.duration;

    return new Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
          child: new TimerText(
              dependencies: dependencies,
              duration: calcDuration,
              hasBeenReset: hasBeenReset),
        ),
        Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Name'))),
        new Expanded(
          flex: 0,
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingButton(
                    dependencies.stopwatch.isRunning ? "lap" : "reset",
                    leftButtonPressed),
                buildFloatingButton(
                    dependencies.stopwatch.isRunning ? "stop" : "start",
                    rightButtonPressed),
                buildFloatingButton(
                    "Save",
                    () => saveActivity(args.id, controller.text,
                        getActualTimeElapsed(args.duration))),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class TimerText extends StatefulWidget {
  final Dependencies dependencies;
  final String duration;
  final bool hasBeenReset;

  TimerText({Key key, this.dependencies, this.duration, this.hasBeenReset});

  TimerTextState createState() => new TimerTextState(
      dependencies: dependencies,
      duration: duration,
      hasBeenReset: hasBeenReset);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies, this.duration, this.hasBeenReset});

  final Dependencies dependencies;
  String duration;
  final bool hasBeenReset;

  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = widget.hasBeenReset
          ? dependencies.stopwatch.elapsedMilliseconds
          : dependencies.stopwatch.elapsedMilliseconds +
              int.parse(widget.duration);
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new RepaintBoundary(
            child: new SizedBox(
              height: 72.0,
              child: new MinutesAndSeconds(dependencies: dependencies),
            ),
          ),
          new RepaintBoundary(
            child: new SizedBox(
              height: 72.0,
              child: new Hundreds(dependencies: dependencies),
            ),
          ),
        ],
      ),
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});

  final Dependencies dependencies;

  MinutesAndSecondsState createState() =>
      new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});

  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});

  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});

  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
