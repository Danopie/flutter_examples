import 'package:flutter/material.dart';
import 'package:for_research/journey_demo.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        backgroundColor: kPrimary,
        scaffoldBackgroundColor: kPrimary,
        dialogBackgroundColor: kPrimary,
      ),
      home: JourneyDemo(),
    );
  }
}
