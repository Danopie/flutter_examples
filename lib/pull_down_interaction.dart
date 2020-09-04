import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_research/hooks.dart';
import 'package:build_context/build_context.dart';

class PullDownInteraction extends StatefulWidget {
  @override
  _PullDownInteractionState createState() => _PullDownInteractionState();
}

class _PullDownInteractionState extends State<PullDownInteraction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: LiquidPullDownIndicator(
          child: Container(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class Triangle {
  final Offset vertices1;
  final Offset vertices2;
  final Offset vertices3;

  Triangle(this.vertices1, this.vertices2, this.vertices3);

  @override
  String toString() {
    return 'Triangle{vertices1: $vertices1, vertices2: $vertices2, vertices3: $vertices3}';
  }
}

class TriangleTween extends Tween<Triangle> {
  TriangleTween({Triangle begin, Triangle end}) : super(begin: begin, end: end);

  @override
  Triangle lerp(double t) {
    print('TriangleTween.lerp: $t');
    final vertices1Tween =
        Tween<Offset>(begin: begin.vertices1, end: end.vertices1);
    final vertices2Tween =
        Tween<Offset>(begin: begin.vertices2, end: end.vertices2);
    final vertices3Tween =
        Tween<Offset>(begin: begin.vertices3, end: end.vertices3);
    return Triangle(
        vertices1Tween.lerp(t), vertices2Tween.lerp(t), vertices3Tween.lerp(t));
  }
}

const double kMinHeight = 0;
const double kTriggerHeight = 200;
const double kPullLimitHeight = 250;
const double kEdgeHeight = 60;

enum PullDownState { Idle, Pulling, Expanding }

class LiquidPullDownIndicator extends StatefulHookWidget {
  final Widget child;

  const LiquidPullDownIndicator({Key key, this.child}) : super(key: key);

  @override
  _LiquidPullDownIndicatorState createState() =>
      _LiquidPullDownIndicatorState();
}

class _LiquidPullDownIndicatorState extends State<LiquidPullDownIndicator>
    with TickerProviderStateMixin {
  double centerOffset;
  PullDownState state;
  AnimationController expandController;
  Animation<double> expandAnimation;
  Animation<double> edgeExpandAnimation;

  @override
  void initState() {
    centerOffset = 0;
    state = PullDownState.Idle;
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    expandController.addListener(() {
      setState(() {
        centerOffset = expandAnimation.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final edgeOffset = _calculateEdgeOffset();

    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is OverscrollNotification) {
          _handleOverScrollNotification(noti);
        } else if (noti is ScrollEndNotification) {
          _handleScrollEndNotification();
        }
        return false;
      },
      child: CustomPaint(
        painter: LiquidPainter(
          centerOffset,
          edgeOffset,
        ),
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          child: widget.child,
        ),
      ),
    );
  }

  void _handleOverScrollNotification(
    OverscrollNotification notification,
  ) {
    if (state != PullDownState.Expanding) {
      final friction = 1 - centerOffset / kPullLimitHeight;
      final value = centerOffset - (notification.overscroll * friction);

      setState(() {
        centerOffset = value.clamp(kMinHeight, kPullLimitHeight);
        if (centerOffset > kTriggerHeight) {
          state = PullDownState.Expanding;
          expandAnimation = expandController.drive(Tween<double>(
              begin: centerOffset, end: context.mediaQuerySize.height));
          edgeExpandAnimation = expandController.drive(Tween<double>(
            begin: kEdgeHeight,
            end: context.mediaQuerySize.height,
          ));
          expandController.forward(from: 0.0);
        }
      });
    }
  }

  void _handleScrollEndNotification() {
    if (state != PullDownState.Expanding) {
      setState(() {
        state = PullDownState.Idle;
        expandAnimation =
            expandController.drive(Tween<double>(begin: 0, end: centerOffset));
        expandController.reverse(from: 1.0);
      });
    }
  }

  double _calculateEdgeOffset() {
    if (state != PullDownState.Expanding) {
      final value = centerOffset.clamp(kMinHeight, kPullLimitHeight);
      final ratio = value / kPullLimitHeight;
      return Tween<double>(begin: 0, end: kEdgeHeight).transform(ratio);
    } else {
      return edgeExpandAnimation.value;
    }
  }
}

class LiquidPainter extends CustomPainter {
  final double centerOffset;
  final double edgeOffset;

  LiquidPainter(this.centerOffset, this.edgeOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final leftPoint = Offset(0, edgeOffset);
    final middlePoint = Offset(size.width / 2, centerOffset);
    final rightPoint = Offset(size.width, edgeOffset);
    final dotPoint = middlePoint.translate(0, 1);
    final paint = Paint()..color = Colors.green;

    _drawPath(leftPoint, middlePoint, rightPoint, canvas, paint, dotPoint);
  }

  void _drawPath(Offset leftPoint, Offset middlePoint, Offset rightPoint,
      Canvas canvas, Paint paint, Offset dotPoint) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(leftPoint.dx, leftPoint.dy);
    path.conicTo(
        middlePoint.dx, middlePoint.dy, rightPoint.dx, rightPoint.dy, 1);
    path.lineTo(rightPoint.dx, rightPoint.dy);
    path.lineTo(rightPoint.dx, 0);
    path.lineTo(0, 0);

    if (middlePoint > Offset.zero) {
      final ratio = (centerOffset / kPullLimitHeight).clamp(0.0, 1.0);
      if (ratio > 0.1 && ratio < 1.0) {
        path.addOval(Rect.fromCenter(
          center: dotPoint,
          width: Tween<double>(begin: 30, end: 20).transform(ratio),
          height: Tween<double>(begin: 30, end: 70).transform(ratio),
        ));
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return oldDelegate.centerOffset != this.centerOffset ||
        oldDelegate.edgeOffset != this.edgeOffset;
  }
}
