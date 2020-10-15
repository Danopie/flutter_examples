import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PhysicalSimulationDemo extends StatefulWidget {
  @override
  _PhysicalSimulationDemoState createState() => _PhysicalSimulationDemoState();
}

class _PhysicalSimulationDemoState extends State<PhysicalSimulationDemo>
    with SingleTickerProviderStateMixin {
  double scale;
  AnimationController controller;

  @override
  void initState() {
    scale = 1.0;
    controller = AnimationController.unbounded(
        vsync: this, duration: Duration(milliseconds: 200));
    controller.addListener(() {
      setState(() {
        scale = controller.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        final simulation = _createSpringAnimation(scale, 0.9);
        await controller.animateWith(simulation);
      },
      onTapUp: (details) async {
        final secondarySimulation = _createSpringAnimation(scale, 1.0);
        await controller.animateWith(secondarySimulation);
      },
      child: Scaffold(
          body: Center(
        child: Transform.scale(
          scale: scale,
          child: Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.orange,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Colors.black12,
                    blurRadius: 4.0,
                  )
                ]),
          ),
        ),
      )),
    );
  }

  SpringSimulation _createSpringAnimation(double start, double end) {
    // final pixelsPerSecond = details.velocity.pixelsPerSecond;
    // final size = MediaQuery.of(context).size;
    // final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    // final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    // final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    // final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    );

    return SpringSimulation(spring, start, end, 0.0);
  }

  static const double _kDrag = 0.0000135;

  GravitySimulation _createGravitySimulation(DragEndDetails details) {
    final sim = GravitySimulation(
      15.0, // acceleration, pixels per second per second
      0.0, // starting position, pixels
      1.0, // ending position, pixels
      0.0, // starting velocity, pixels per second
    );
    return sim;
  }
}
