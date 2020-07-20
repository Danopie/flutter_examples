import 'dart:math';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ScrollController();

  final List<int> pages = List.generate(4, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          physics: CustomScrollPhysics(length: pages.length),
          itemCount: pages.length,
          itemBuilder: (context, index) => Container(
            height: double.infinity,
            width: 300,
            color: randomColor,
            margin: const EdgeInsets.all(20.0),
          ),
        ),
      ),
    );
  }

  Color get randomColor =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
}

class CustomScrollPhysics extends ScrollPhysics {
  final int length;

  CustomScrollPhysics({this.length, ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(length: length, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / getItemDimension(position);
  }

  double _getPixels(double page, ScrollPosition position) {
    return page * getItemDimension(position);
  }

  double getItemDimension(ScrollPosition position) {
    return position.maxScrollExtent / (length - 1);
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble(), position);
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
