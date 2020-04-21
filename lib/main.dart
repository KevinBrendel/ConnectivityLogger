import 'package:connectivity_logger/LifeCycleEventHandler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';

import 'logger.dart';

void main() async {
  runApp(MyApp());
  await [
    Permission.location,
    Permission.storage,
  ].request();
  Screen.keepOn(true);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Logger',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Connectivity Logger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Logger logger;

  _MyHomePageState() {
    logger = new Logger(_incrementCounter);
  }

  @override
  void initState() {
    super.initState();
    logger.start();
    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(detachedCallBack: () => logger.saveData(), resumeCallBack: () => logger.start()));
  }

  @override
  void dispose() {
    logger.stop();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Widget labelButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          onPressed: () => logger.addLabel(label),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              label,
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              'Logged WiFi this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            Spacer(),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  labelButton("1"),
                  labelButton("2"),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  labelButton("3"),
                  labelButton("4"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
