import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:for_research/hooks.dart';
import 'package:for_research/journey_demo.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/same_key.dart';
import 'package:for_research/slivers.dart';

void main() {
  runApp(DevicePreview(
    builder: (_) => MyApp(),
    enabled: true,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder,

      theme: Theme.of(context).copyWith(
        backgroundColor: kPrimary,
        scaffoldBackgroundColor: kPrimary,
        dialogBackgroundColor: kPrimary,
      ),
      home: AppBarSnapDemo(),
    );
  }
}
