import 'package:flutter/material.dart';
import 'package:for_research/animated_list_demo.dart';
import 'package:for_research/bottom_tab_animated.dart';
import 'package:for_research/nested_scroll_view_issue.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/neumorphic_animated_player/neumorphism.dart';
import 'package:for_research/neumorphic_animated_player/player_page.dart';
import 'package:for_research/parallel_scroll_view.dart';


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
      home: AnimatedListDemo(),
    );
  }
}
