import 'package:flutter/material.dart';

class MatrixDemo extends StatefulWidget {
  @override
  _MatrixDemoState createState() => _MatrixDemoState();
}

class _MatrixDemoState extends State<MatrixDemo> {
  double x = 0;
  double y = 0;
  double z = 0;

  @override
  Widget build(BuildContext context) {
    print('_MatrixDemoState.build: $x $y');
    return Scaffold(
      body: Center(
        child: Transform(
          transform: Matrix4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0.002,
            0, 0, 0, 1,
          )
            ..rotateX(x)
            ..rotateY(y)
            ..rotateZ(z),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                y = y - details.delta.dx / 100;
                x = x + details.delta.dy / 100;
              });
            },
            child: Container(
              color: Colors.red,
              height: 200,
              width: 200.0,
              child: SizedBox(
                height: 400,
                width: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


