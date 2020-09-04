import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSliver extends StatefulWidget {
  @override
  _CustomSliverState createState() => _CustomSliverState();
}

class _CustomSliverState extends State<CustomSliver> {
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        boundaryMargin: EdgeInsets.all(50.0),
        minScale: 0.1,
        maxScale: 5,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "https://images.squarespace-cdn.com/content/v1/5a5906400abd0406785519dd/1552662149940-G6MMFW3JC2J61UBPROJ5/ke17ZwdGBToddI8pDm48kLkXF2pIyv_F2eUT9F60jBl7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iyqMbMesKd95J-X4EagrgU9L3Sa3U8cogeb0tjXbfawd0urKshkc5MgdBeJmALQKw/baelen.jpg?format=1500w"))),
          child: Placeholder(),
        ),
      ),
    );
  }
}

class SliverDan extends SingleChildRenderObjectWidget {
  final Widget child;

  SliverDan({this.child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverDan();
  }
}

class RenderSliverDan extends RenderSliverPersistentHeader {
  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double maxExtent = 40;
    final bool overlapsContent = constraints.overlap > 0.0;
    excludeFromSemanticsScrolling =
        overlapsContent || (constraints.scrollOffset > maxExtent - minExtent);
    layoutChild(constraints.scrollOffset, maxExtent,
        overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
        max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (maxExtent - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent) as double;
    final double stretchOffset =
        stretchConfiguration != null ? constraints.overlap.abs() : 0.0;
    print(
        'RenderSliverDan.performLayout: ${constraints.overlap}\n----------------\n');
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: 0,
      paintExtent:
          min(childExtent, effectiveRemainingPaintExtent) + stretchOffset,
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent + stretchOffset,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;
}
