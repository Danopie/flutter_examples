import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/sliver_app_bar_snap.dart';
import 'package:for_research/slivers.dart';

void main() {
  runApp(DevicePreview(
    builder: (_) => MyApp(),
    enabled: false,
  ));
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
      builder: DevicePreview.appBuilder,
      home: SliverAppBarSnap(),
    );
  }
}
