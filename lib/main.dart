import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/vin_id_appbar.dart';

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
      theme: Theme.of(context).copyWith(
        backgroundColor: kPrimary,
        scaffoldBackgroundColor: kPrimary,
        dialogBackgroundColor: kPrimary,
      ),
      locale: DevicePreview.of(context).locale,
      builder: DevicePreview.appBuilder,

      home: VinIDHomeAppBarDemo(),
    );
  }
}
