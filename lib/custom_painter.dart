import 'dart:math';

import 'package:flutter/material.dart';

class TestCustomPainter extends StatefulWidget {
  @override
  _TestCustomPainterState createState() => _TestCustomPainterState();
}

class _TestCustomPainterState extends State<TestCustomPainter>
    with TickerProviderStateMixin<TestCustomPainter> {
  double percentage;
  double newPercentage;
  AnimationController controller;
  Tween<double> tween;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    percentage = 0.0;
    newPercentage = 0.0;
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Research"),
        ),
        body: Center(
          child: Container(
            height: 200,
            width: 200,
            child: AnimatedBuilder(
              child: Container(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  color: Colors.purple,
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    setState(() {
                      percentage = newPercentage;
                      newPercentage += 10.0;
                      print(
                          '_MyHomePageState.build: newPercentage:$newPercentage, percentage: $percentage');
                      if (newPercentage > 100.0) {
                        percentage = 0.0;
                        newPercentage = 0.0;
                      }
                      controller.forward(from: 0.0);
                    });
                  },
                  child: Text("Click me"),
                  shape: CircleBorder(),
                ),
              ),
              builder: (BuildContext context, Widget child) {
                print('_MyHomePageState.build: animation ${controller.value}');
                percentage = Tween(begin: percentage, end: newPercentage)
                    .animate(controller)
                    .value;
                return CustomPaint(
                  foregroundPainter: MyPainter(completePercent: percentage),
                  child: child,
                );
              },
              animation: controller,
            ),
          ),
        ));
    ;
  }
}

class MyPainter extends CustomPainter {
  double completePercent;
  MyPainter({this.completePercent});
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.orange
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final complete = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
