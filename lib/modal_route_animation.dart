import 'package:flutter/material.dart';

class ModalRouteAnimationDemo extends StatefulWidget {
  @override
  _ModalRouteAnimationDemoState createState() =>
      _ModalRouteAnimationDemoState();
}

class _ModalRouteAnimationDemoState extends State<ModalRouteAnimationDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/b");
        },
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 0), end: Offset(-3, 0))
              .animate(ModalRoute.of(context).secondaryAnimation),
          child: Container(
            height: 200,
            width: 200,
            color: Colors.green,
          ),
        ),
      )),
    );
  }
}

class PageB extends StatefulWidget {
  @override
  _PageBState createState() => _PageBState();
}

class _PageBState extends State<PageB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SlideTransition(
                position: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                    .animate(ModalRoute.of(context).animation),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 300,
                    width: 300,
                    color: Colors.red,
                  ),
                ),
              ),
              SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(ModalRoute.of(context).animation),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 300,
                    width: 300,
                    color: Colors.yellow,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
