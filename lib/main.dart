import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:for_research/immutability.dart';
import 'package:for_research/messenger_clone.dart';
import 'package:for_research/mini_player.dart';
import 'package:for_research/nested_new_navigators.dart';
import 'package:for_research/netflix_logo.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/sendo_bus_banner.dart';

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
      locale: DevicePreview.of(context).locale,
      builder: DevicePreview.appBuilder,
      home: SendoBusBanner(),
    );
  }
}
