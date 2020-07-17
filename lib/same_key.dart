import 'package:flutter/material.dart';

class SameKeyDemo extends StatefulWidget {
  @override
  _SameKeyDemoState createState() => _SameKeyDemoState();
}

class _SameKeyDemoState extends State<SameKeyDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 100,
                width: 100,
                color: Colors.green,
                key: ValueKey("AAA"),
              ),
            ],
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SameKeyDemo()));
            },
          ),
        ],
      ),
    );
  }
}
