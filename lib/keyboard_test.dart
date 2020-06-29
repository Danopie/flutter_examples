import 'package:flutter/material.dart';

class TestKeyboard extends StatefulWidget {
  @override
  _TestKeyboardState createState() => _TestKeyboardState();
}

class _TestKeyboardState extends State<TestKeyboard> {
  var _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (key) {},
            child: TextField(key: Key('PinInput_1'), focusNode: _focusNode)),
      ),
    );
  }
}
