import 'dart:math';
import 'dart:ui' as UI;

import 'package:flutter/material.dart';

class NetflixLogoDemo extends StatefulWidget {
  @override
  _NetflixLogoDemoState createState() => _NetflixLogoDemoState();
}

class _NetflixLogoDemoState extends State<NetflixLogoDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: NetflixLogo(),
      ),
    );
  }
}

class NetflixLogo extends StatefulWidget {
  @override
  _NetflixLogoState createState() => _NetflixLogoState();
}

class _NetflixLogoState extends State<NetflixLogo>
    with TickerProviderStateMixin {
  AnimationController rightController;
  AnimationController centerController;
  AnimationController leftController;
  AnimationController zoomController;

  @override
  void initState() {
    rightController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    centerController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    leftController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    zoomController =
        AnimationController(vsync: this, duration: Duration(seconds: 5));

    rightController.addListener(() {
      if (rightController.value > 0.5 && centerController.isDismissed) {
        centerController.forward(from: 0.0);
      }
    });

    centerController.addListener(() {
      if (centerController.value > 0.6 && leftController.isDismissed) {
        leftController.forward(from: 0.0);
      }
    });

    startAnimation();

    super.initState();
  }

  void startAnimation() {
    zoomController.forward(from: 0.0);

    Future.delayed(Duration(milliseconds: 800), () {
      rightController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: zoomController,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 1.0, end: 50.0)
              .chain(CurveTween(curve: Cubic(1.0, 0.01, 1.0, -0.05)))
              .evaluate(zoomController),
          alignment: Alignment(-0.8, 0),
          child: child,
        );
      },
      child: CustomPaint(
        painter: RightLinePainter(rightController),
        child: CustomPaint(
          painter: LeftLinePainter(leftController),
          child: CustomPaint(
            painter: CenterLinePainter(centerController),
            child: SizedBox(
              height: 270,
              width: 150,
            ),
          ),
        ),
      ),
    );
  }
}

const heavyRed = Color(0xFFB00712);
const lightRed = Color(0xFFE50915);
final lineWidth = 50.0;
final legOffset = 5.0;

class RightLinePainter extends CustomPainter {
  final Animation<double> animation;

  RightLinePainter(this.animation) : super(repaint: animation);

  Map<double, double> endYMap = Map<double, double>();
  Map<double, Interval> endYIntervalMap = Map<double, Interval>();

  @override
  void paint(Canvas canvas, Size size) {
    drawRightLine(canvas, size, lineWidth, legOffset);
  }

  void drawRightLine(
      Canvas canvas, Size size, double lineWidth, double legOffset) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = heavyRed;

    for (double i = size.width - lineWidth; i <= size.width; i += 1.0) {
      final startYValue =
          legOffset * (i) / (lineWidth) + size.height - legOffset;
      double endYValue = 0.0;

      if (endYMap.containsKey(i)) {
        endYMap[i] = Tween<double>(begin: 0.0, end: startYValue)
            .chain(CurveTween(curve: endYIntervalMap[i]))
            .chain(CurveTween(curve: Curves.decelerate))
            .evaluate(animation);
        endYValue = endYMap[i];
      } else {
        endYMap[i] = 0.0;
        endYIntervalMap[i] =
            randomInterval(i >= 1.0 ? endYIntervalMap[i - 1.0] : null);
      }

      final path = Path();
      path.moveTo(i, startYValue);
      path.lineTo(i, endYValue);

      final rect =
          Rect.fromPoints(Offset(i, startYValue), Offset(i, endYValue));

      paint.shader = UI.Gradient.linear(Alignment.bottomCenter.withinRect(rect),
          Alignment.topCenter.withinRect(rect), [
        heavyRed,
        ColorTween(begin: heavyRed, end: Colors.transparent).evaluate(animation)
      ]);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(RightLinePainter oldDelegate) {
    return true;
  }
}

class CenterLinePainter extends CustomPainter {
  final Animation<double> animation;

  CenterLinePainter(this.animation) : super(repaint: animation);

  Map<double, Interval> endYIntervalMap = Map<double, Interval>();

  @override
  void paint(Canvas canvas, Size size) {
    drawCenterLine(lineWidth, size, canvas, legOffset);
  }

  void drawCenterLine(
      double lineWidth, Size size, Canvas canvas, double legOffset) {
    final upperPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = lightRed;

    drawShadow(lineWidth, size, legOffset, canvas);

    drawLines(lineWidth, legOffset, size, canvas, upperPaint);
  }

  void drawLines(double lineWidth, double legOffset, Size size, Canvas canvas,
      Paint upperPaint) {
    for (double i = 0.0; i <= lineWidth; i += 1.0) {
      final startYValue =
          legOffset * (i) / (lineWidth) + (size.height - legOffset);
      final path = Path();

      final beginOffset =
          Offset(size.width - lineWidth + i, startYValue + 10.0);
      final endOffset = Offset(i, 0);

      if (!endYIntervalMap.containsKey(i)) {
        endYIntervalMap[i] = randomInterval(null);
      }

      final offset = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      )
          .chain(CurveTween(curve: endYIntervalMap[i]))
          .chain(CurveTween(curve: Curves.decelerate))
          .evaluate(animation);

      final colorOpacity = offset.dy / (startYValue + 10.0);
      upperPaint.color = lightRed.withOpacity(colorOpacity);

      path.moveTo(endOffset.dx, endOffset.dy);
      path.lineTo(offset.dx, offset.dy);
      path.close();

      upperPaint.shader = UI.Gradient.linear(
          Alignment.topCenter.withinRect(Rect.fromPoints(endOffset, offset)),
          Alignment.bottomCenter.withinRect(Rect.fromPoints(endOffset, offset)),
          [
            lightRed,
            ColorTween(begin: lightRed, end: Colors.transparent)
                .evaluate(animation)
          ]);

      canvas.drawPath(path, upperPaint);
    }
  }

  void drawShadow(
      double lineWidth, Size size, double legOffset, Canvas canvas) {
    final path = Path();
    path.lineTo(lineWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - lineWidth, size.height - legOffset);
    path.lineTo(0, 0);
    canvas.drawShadow(path,
        Color(0xFF89010D).withOpacity(1.0 - animation.value), 16.0, false);
  }

  @override
  bool shouldRepaint(CenterLinePainter oldDelegate) {
    return true;
  }
}

Interval randomInterval(Interval previousInterval) {
  if (previousInterval == null) previousInterval = Interval(0.0, 1.0);
  final min = Random().nextDouble();
  final max = (Random().nextDouble() + min).clamp(0.0, 1.0);
  return Interval(min, max);
}

class LeftLinePainter extends CustomPainter {
  final Animation<double> animation;

  LeftLinePainter(this.animation) : super(repaint: animation);

  static Map<double, Color> colors = Map<double, Color>();

  @override
  void paint(Canvas canvas, Size size) {
    drawLeftLine(canvas, lineWidth, size, legOffset);
  }

  void drawLeftLine(
      Canvas canvas, double lineWidth, Size size, double legOffset) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = heavyRed;

    for (double i = 0; i < lineWidth; i += 1.0) {
      final value =
          -legOffset * (i - size.width + lineWidth) / (lineWidth) + size.height;

      final path = Path();
      path.moveTo(i, 0.0);
      path.lineTo(i, value);

      if (!colors.containsKey(i)) {
        colors[i] = _getRandomColor(i - 1.0);
      }

      final color =
          ColorTween(begin: heavyRed, end: colors[i]).evaluate(animation);

      final gradientWidth = Tween<double>(begin: 0.1, end: 2.0).evaluate(animation);

      final rect = Rect.fromPoints(Offset(i - gradientWidth, 0.0), Offset(i + gradientWidth, value));

      paint.shader = UI.Gradient.linear(Alignment.centerLeft.withinRect(rect),
          Alignment.centerRight.withinRect(rect), [
        ColorTween(begin: heavyRed, end: Colors.transparent)
            .evaluate(animation),
        ColorTween(begin: heavyRed, end: color).evaluate(animation),
        ColorTween(begin: heavyRed, end: Colors.transparent)
            .evaluate(animation),
      ], [
        0.2,
        0.5,
        0.9,
      ]);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LeftLinePainter oldDelegate) {
    return true;
  }

  static List<Color> kColors = [
    Colors.red,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.blue,
    Colors.deepOrange,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.orange,
    Colors.purpleAccent
  ];

  Color _getRandomColor(double previousKey) {
    final isTransparent = Random().nextBool();
    if (isTransparent) return Colors.transparent;

    final color = colors[previousKey];
    final colorIndex = kColors.indexOf(color);

    if (colorIndex < 0) return kColors.first;
    if (colorIndex == kColors.length - 1) return kColors.first;

    return kColors[colorIndex + 1];
  }
}
