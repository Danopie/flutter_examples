import 'dart:math';

import 'package:flutter/material.dart';
import 'package:for_research/neumorphic_animated_player/colors.dart';
import 'package:for_research/neumorphic_animated_player/neumorphism.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPlayerDemo extends StatefulWidget {
  @override
  _AnimatedPlayerDemoState createState() => _AnimatedPlayerDemoState();
}

class _AnimatedPlayerDemoState extends State<AnimatedPlayerDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  NeuBackButton(),
                ],
              ),
              Container(
                height: 24,
              ),
              SongThumbnail(),
              Container(
                height: 24,
              ),
              Text(
                "Beautiful Now",
                style: GoogleFonts.daysOne().copyWith(
                  fontSize: 24,
                  color: kGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                height: 8,
              ),
              Text(
                "Zedd.",
                style: TextStyle(
                  fontSize: 18,
                  color: kDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                height: 42,
              ),
              TrackTimeline(),
              Container(
                height: 42,
              ),
              TrackController(),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        NeuContainer(
          width: 60,
          height: 60,
          style: NeuStyle.Flat,
          radius: BorderRadius.circular(60 / 2),
          child: Icon(
            Icons.skip_previous,
            color: kGrey,
          ),
          onTap: (){},
        ),
        Container(width: 24,),
        NeuContainer(
          width: 80,
          height: 80,
          color: kAccent,
          style: NeuStyle.Flat,
          radius: BorderRadius.circular(80 / 2),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
          onTap: (){},
        ),
        Container(width: 24,),
        NeuContainer(
          width: 60,
          height: 60,
          style: NeuStyle.Flat,
          radius: BorderRadius.circular(60 / 2),
          child: Icon(
            Icons.skip_next,
            color: kGrey,
          ),
          onTap: (){},
        )
      ],
    );
  }
}

class TrackTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          "1:17",
          style: GoogleFonts.daysOne().copyWith(
            fontSize: 16,
            color: kGrey,
            fontWeight: FontWeight.w200,
          ),
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: TrackProgress())),
        Text(
          "2:46",
          style: GoogleFonts.daysOne().copyWith(
            fontSize: 16,
            color: kGrey,
            fontWeight: FontWeight.w200,
          ),
        )
      ],
    );
  }
}

class TrackProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = List<Widget>();
        final margin = 5.0;
        final itemWidth = 5.0;
        final width = constraints.maxWidth;
        final itemCounts = width ~/ (itemWidth + margin);
        for (int i = 0; i < itemCounts; i++) {
          final height = Random().nextInt(20) + 5;
          final color = i < itemCounts * 1 / 3 ? kGrey : null;
          w.add(NeuContainer(
            width: itemWidth,
            color: color,
            style: NeuStyle.Emboss,
            radius: BorderRadius.circular(height / 2),
            height: height.toDouble(),
          ));
          w.add(Container(
            width: itemWidth,
          ));
        }

        w.removeLast();

        return Row(
          children: w,
        );
      },
    );
  }
}

class SongThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height / 3;
    final diskBorderSize = 14;
    final sizeWithoutBorder = size - diskBorderSize;
    final innerCircleSize = size / 2.3;

    return CustomPaint(
      foregroundPainter: CirclePainter(),
      child: NeuContainer(
        height: size,
        width: size,
        style: NeuStyle.Convex,
        distance: 20,
        radius: BorderRadius.circular(size / 2),
        child: NeuContainer(
          height: sizeWithoutBorder,
          width: sizeWithoutBorder,
          style: NeuStyle.Flat,
          hasShadow: false,
          radius: BorderRadius.circular(sizeWithoutBorder / 2),
          child: NeuContainer(
            height: innerCircleSize,
            width: innerCircleSize,
            hasShadow: false,
            radius: BorderRadius.circular(innerCircleSize / 2),
            child: ClipOval(
              child: Image.network(
                "https://upload.wikimedia.org/wikipedia/vi/c/c9/Zedd-True-Colors.png",
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2 - 14;
    final limitRadius = radius - 40;
    final margin = 5.0;
    final paint = Paint()
      ..color = kDark.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = radius; i > limitRadius; i -= margin) {
      canvas.drawCircle(size.center(Offset.zero), i, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class NeuBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      style: NeuStyle.Emboss,
      width: 40,
      height: 40,
      radius: BorderRadius.circular(8),
      padding: EdgeInsets.all(8),
      onTap: (){},
      child: Icon(
        Icons.arrow_back,
        color: kDark,
      ),
    );
  }
}
