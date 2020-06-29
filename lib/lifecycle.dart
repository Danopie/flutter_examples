import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

final RouteObserver<PageRoute> observer = new RouteObserver<PageRoute>();

abstract class LifeCycleState<T extends StatefulWidget> extends State<T> {
  LifeCycleState() {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg.toString() == AppLifecycleState.resumed.toString()) {
        onResume();
      } else if (msg.toString() == AppLifecycleState.paused.toString()) {
        onPause();
      } else if (msg.toString() == AppLifecycleState.inactive.toString()) {
        print("onInactive");
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      onFirstFrame();
    });
  }

  void onResume() {
    print('A.onResume');
  }

  void onPause() {
    print('A.onPause');
  }

  void onFirstFrame() {
    print('A.onFirstFrame');
  }
}

class W extends StatefulWidget {
  @override
  _WState createState() => _WState();
}

class _WState extends LifeCycleState<W> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => W()));
      }),
    );
  }

  @override
  void log() {
    print('W.log');
  }

  @override
  void onPause() {
    print('_WState.onPause');
  }

  @override
  void onResume() {
    print('_WState.onResume');
  }

  @override
  void onFirstFrame() {
    print('_WState.onFirstFrame');
  }
}
