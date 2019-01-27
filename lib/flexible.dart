import 'package:flutter/material.dart';

class TestFlexible extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buildA() => Container(
          color: Colors.red,
        );
    Widget buildB() => Container(
          color: Colors.green,
        );

    return Scaffold(
      appBar: AppBar(),
      body: Container(
          height: 40,
          child: Row(
            children: <Widget>[
              Flexible(child: buildA(), flex: 1,),
              Flexible(child: buildB(), flex: 2,),
            ],
          )),
    );
  }
}
