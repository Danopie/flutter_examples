import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollingInteractionsDemo extends StatefulWidget {
  @override
  _ScrollingInteractionsDemoState createState() =>
      _ScrollingInteractionsDemoState();
}

final kGrey = Colors.grey[300];
final kBlack = Colors.black12;

class _ScrollingInteractionsDemoState extends State<ScrollingInteractionsDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WidgetImplementation(),
    );
  }
}

const kDistanceToTop = 350.0;

class WidgetImplementation extends StatefulWidget {
  @override
  _WidgetImplementationState createState() => _WidgetImplementationState();
}

class _WidgetImplementationState extends State<WidgetImplementation> {
  double topDistancePercentage = 0;
  double extraForwardExtent = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: _handleScrollChange,
      child: Stack(children: [
        WidgetAppBarBackground(
          heightRatio: topDistancePercentage,
          extraExtent: extraForwardExtent,
        ),
        WidgetListSample(
          widthRatio: topDistancePercentage,
        ),
        WidgetAppBar(
          heightRatio: topDistancePercentage,
        ),
      ]),
    );
  }

  bool _handleScrollChange(ScrollUpdateNotification notification) {
    final currentDistanceToTop =
        notification.metrics.pixels.clamp(0, kDistanceToTop);
    Future.microtask(
      () => setState(
        () {
          topDistancePercentage = currentDistanceToTop / kDistanceToTop;
          if (notification.metrics.pixels < 0) {
            extraForwardExtent = notification.metrics.pixels.abs();
          }
          print('$extraForwardExtent');
        },
      ),
    );

    return false;
  }
}

class WidgetAppBar extends StatelessWidget {
  final double heightRatio;

  const WidgetAppBar({Key key, this.heightRatio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double colorOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Interval(0.7, 1.0)))
        .transform(heightRatio);
    Offset titleOffset = Tween<Offset>(begin: Offset(0, 50), end: Offset.zero)
        .chain(CurveTween(curve: Interval(0.7, 1.0)))
        .transform(heightRatio);

    final appBar = _buildAppBar(colorOpacity, titleOffset);

    return SizedBox(
      height: appBar.preferredSize.height + MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: colorOpacity,
              child: Material(
                color: Color(0xFF2672FB),
                elevation: colorOpacity > 0.9 ? 4 : 0,
              ),
            ),
          ),
          appBar,
        ],
      ),
    );
  }

  AppBar _buildAppBar(double colorOpacity, Offset titleOffset) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      title: Transform.translate(
        offset: titleOffset,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
            ),
            Container(
              width: 16,
            ),
            Container(
              height: 16,
              width: 100,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetAppBarBackground extends StatelessWidget {
  final double heightRatio;
  final double extraExtent;

  const WidgetAppBarBackground({Key key, this.heightRatio, this.extraExtent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 400.0 + extraExtent;
    return Container(
      height: Tween<double>(begin: appBarHeight, end: kToolbarHeight)
          .transform(heightRatio),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF4ADFFC),
            Color(0xFF267CF7),
          ])),
      child: OverflowBox(
        maxHeight: appBarHeight,
        child: Opacity(
            opacity: Tween<double>(begin: 1.0, end: 0.0).transform(heightRatio),
            child: TopPlaceholder()),
      ),
    );
  }
}

class WidgetListSample extends StatelessWidget {
  final double widthRatio;

  const WidgetListSample({Key key, this.widthRatio}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: kDistanceToTop),
      itemBuilder: (context, index) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: Tween<double>(begin: 32, end: 0).transform(widthRatio),
          ),
          child: _buildItem()),
      itemCount: 20,
    );
  }

  Widget _buildItem() => Material(
        elevation: 8,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: kGrey,
                  ),
                  Container(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 24,
                        width: 150,
                        color: kGrey,
                      ),
                      Container(
                        height: 12,
                      ),
                      Container(
                        height: 16,
                        width: 100,
                        color: kGrey,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
          ],
        ),
      );
}

class TopPlaceholder extends StatelessWidget {
  const TopPlaceholder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: kBlack,
        ),
        Container(
          height: 16,
        ),
        Container(
          height: 24,
          width: 240,
          color: kBlack,
        ),
        Container(
          height: 16,
        ),
        Container(
          height: 16,
          width: 160,
          color: kBlack,
        ),
      ],
    );
  }
}
