import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'dart:math' as math;

class MovieBannerTestPage extends StatefulWidget {
  @override
  _MovieBannerTestPageState createState() => _MovieBannerTestPageState();
}

class _MovieBannerTestPageState extends State<MovieBannerTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PosterBanner(),
      ),
    );
  }
}

class OverflowTest extends StatefulWidget {
  @override
  _OverflowTestState createState() => _OverflowTestState();
}

class _OverflowTestState extends State<OverflowTest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      color: Colors.green,
      child: OverflowBox(
        maxHeight: 100,
        maxWidth: 100,
        child: Container(
          color: Colors.orange,
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}

const VIEWPORT_FRACTION = 0.65;

class PosterBanner extends StatefulWidget {
  @override
  _PosterBannerState createState() => _PosterBannerState();
}

class _PosterBannerState extends State<PosterBanner> {
  List<String> images = [
    "https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_SY1000_CR0,0,674,1000_AL_.jpg",
    "https://i.pinimg.com/474x/24/f8/d8/24f8d83809178677cfd87574d1184f7f.jpg",
    "https://m.media-amazon.com/images/M/MV5BNDU4Mzc3NzE5NV5BMl5BanBnXkFtZTgwMzE1NzI1NzM@._V1_SY1000_CR0,0,674,1000_AL_.jpg"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: (320 + 12).toDouble(),
      child: Swiper(
        viewportFraction: VIEWPORT_FRACTION,
        itemBuilder: (BuildContext context, int index) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return OverflowBox(
                maxWidth: constraints.maxWidth + 20,
                maxHeight: constraints.maxHeight + 20,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            spreadRadius: 2)
                      ]),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: new Image.network(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
        itemCount: images.length,
        layout: SwiperLayout.DEFAULT,
        transformer: PosterPageTransformer(images.length),
      ),
    );
  }
}

class PosterPageTransformer extends PageTransformer {
  final int length;

  PosterPageTransformer(this.length);

  final fadeTween = Tween<double>(begin: 1.0, end: 0.4);
  final rotateTween = Tween<double>(begin: 0, end: math.pi / 4.5);
  final scaleTween = Tween<double>(begin: 1.0, end: 0.8);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double animation = mapToAnimationValue(info.position);

    if (childIsLeftOfActive(info)) {
      return Opacity(
        opacity: fadeTween.lerp(animation),
        child: Transform.scale(
          scale: scaleTween.lerp(animation),
          alignment: Alignment.centerRight,
          child: Transform(
            origin: Offset.zero,
            alignment: Alignment.centerRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-rotateTween.lerp(animation)),
            child: child,
          ),
        ),
      );
    } else if (childIsRightOfActive(info)) {
      return Opacity(
        opacity: fadeTween.lerp(animation),
        child: Transform.scale(
          alignment: Alignment.centerLeft,
          scale: scaleTween.lerp(animation),
          child: Transform(
            origin: Offset.zero,
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotateTween.lerp(animation)),
            child: child,
          ),
        ),
      );
    }

    return child;
  }

  bool childIsLeftOfActive(TransformInfo info) {
    if (info.activeIndex > 0 && info.activeIndex < length) {
      return info.index == info.activeIndex - 1;
    } else if (info.activeIndex == 0) {
      return info.index == length - 1;
    }
  }

  bool childIsRightOfActive(TransformInfo info) {
    if (info.activeIndex >= 0 && info.activeIndex < length - 1) {
      return info.index == info.activeIndex + 1;
    } else if (info.activeIndex == length - 1) {
      return info.index == 0;
    }
  }

  double mapToAnimationValue(double positionValue) {
    final interval = (positionValue.abs()) / (VIEWPORT_FRACTION);
    if (interval < 0) return 0;
    if (interval > 1) return 1;
    return interval;
  }
}
