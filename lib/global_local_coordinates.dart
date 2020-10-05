import 'package:flutter/material.dart';

class GlobalAndLocalCoordinates extends StatefulWidget {
  @override
  _GlobalAndLocalCoordinatesState createState() =>
      _GlobalAndLocalCoordinatesState();
}

class _GlobalAndLocalCoordinatesState extends State<GlobalAndLocalCoordinates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              RenderBox box = context.findRenderObject();
              print(
                  '_GlobalAndLocalCoordinatesState.build: ${box.localToGlobal(Offset.zero)}');
              print(
                  '_GlobalAndLocalCoordinatesState.build: ${box.globalToLocal(Offset(162.5, 308.5))}');
            },
            child: Container(
              height: 50,
              width: 50,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
