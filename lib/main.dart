import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:for_research/bottom_tab_animated.dart';
import 'package:for_research/flexible.dart';
import 'package:for_research/slivers.dart';
import 'package:rect_getter/rect_getter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SliverExample(),
    );
  }
}


