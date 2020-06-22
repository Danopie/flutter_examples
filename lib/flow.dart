import 'package:flutter/material.dart';
import 'dart:math';

class FlowDemo extends StatefulWidget {
  @override
  _FlowDemoState createState() => _FlowDemoState();
}

class _FlowDemoState extends State<FlowDemo>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.isDismissed) {
            controller.forward();
          } else {
            controller.reverse();
          }
        },
      ),
      body: Flow(
        delegate: SpreadFlowDelegate(
            CurvedAnimation(parent: controller, curve: Curves.easeIn)),
        children: List.generate(10, (i) => Page(i)),
      ),
    );
  }
}

class Page extends StatelessWidget {
  final int index;

  Page(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey[800], width: 3)),
      child: Scaffold(
        backgroundColor: index % 2 == 0 ? Colors.blueAccent : Colors.red,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Page $index"),
        ),
      ),
    );
  }
}

class SpreadFlowDelegate extends FlowDelegate {
  Animation<double> animation;

  SpreadFlowDelegate(this.animation) : super(repaint: animation);

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final offset = Tween<double>(begin: 0, end: 50.0 * i).evaluate(animation);
      final matrix = Matrix4.translationValues(0, offset, 1.0);

      final opacity = i == context.childCount - 1
          ? 1.0
          : Tween<double>(begin: 0, end: 0.7).evaluate(animation);
      context.paintChild(i, transform: matrix, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(SpreadFlowDelegate oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}
