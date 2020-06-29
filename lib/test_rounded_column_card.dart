import 'package:flutter/material.dart';

class TestRoundedColumnCard extends StatefulWidget {
  @override
  _TestRoundedColumnCardState createState() => _TestRoundedColumnCardState();
}

class _TestRoundedColumnCardState extends State<TestRoundedColumnCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          child: Column(
            children: <Widget>[
              RoundedContainer(height: 20),
              RoundedContainer(height: 60),
              RoundedContainer(height: 40),
            ],
          ),
        ));
  }
}

class RoundedContainer extends StatelessWidget {
  final double height;

  const RoundedContainer({Key key, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(height / 2)),
    );
  }
}
