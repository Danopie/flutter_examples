import 'dart:math';

import 'package:flutter/material.dart';

class SendoBusBanner extends StatefulWidget {
  @override
  _SendoBusBannerState createState() => _SendoBusBannerState();
}

class _SendoBusBannerState extends State<SendoBusBanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BannerScene(),
      ),
    );
  }
}

class BannerScene extends StatefulWidget {
  @override
  _BannerSceneState createState() => _BannerSceneState();
}

class _BannerSceneState extends State<BannerScene> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      color: Colors.grey[200],
      child: Stack(
        children: [
          Positioned(left: 100, top: 100, child: Bus()),
          Positioned(
            left: 60,
            top: 40,
            child: Phone(),
          ),
        ],
      ),
    );
  }
}

class Bus extends StatefulWidget {
  @override
  _BusState createState() => _BusState();
}

class _BusState extends State<Bus> with TickerProviderStateMixin {
  AnimationController _driveController;

  @override
  void initState() {
    _driveController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _driveController.forward(from: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    _driveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _driveController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(begin: Offset(-300, 0), end: Offset(0, 0))
              .chain(CurveTween(curve: Curves.easeOutBack))
              .evaluate(_driveController),
          child: ShakingObject(
            child: child,
          ),
        );
      },
      child: Container(
        height: 140,
        width: 200,
        color: Colors.red,
      ),
    );
  }
}

class ShakingObject extends StatefulWidget {
  final Widget child;

  const ShakingObject({Key key, this.child}) : super(key: key);

  @override
  _ShakingObjectState createState() => _ShakingObjectState();
}

class _ShakingObjectState extends State<ShakingObject>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _magnitudeController;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    _controller.repeat(reverse: true);

    _magnitudeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _magnitudeController.forward(from: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _magnitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _magnitudeController,
      builder: (context, child) {
        return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                child: child,
                offset: Tween<Offset>(begin: Offset(0, 0), end: Offset(0, 1))
                    .evaluate(_controller),
              );
            },
            child: widget.child);
      },
    );
  }
}

class Phone extends StatefulWidget {
  @override
  _PhoneState createState() => _PhoneState();
}

class _PhoneState extends State<Phone> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _controller.forward(from: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: ElasticOutCurve(0.9)))
              .chain(CurveTween(curve: Interval(0.0, 0.7)))
              .evaluate(_controller),
          child: Transform.translate(
            child: child,
            offset: Tween<Offset>(begin: Offset(0, 200), end: Offset(0, 0))
                .chain(CurveTween(curve: ElasticOutCurve(0.9)))
                .evaluate(_controller),
          ),
        );
      },
      child: Container(
        height: 250,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.blue,
        ),
      ),
    );
  }
}
