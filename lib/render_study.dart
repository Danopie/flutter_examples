import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:for_research/vin_id_appbar.dart';

class RenderStudy extends StatefulWidget {
  @override
  _RenderStudyState createState() => _RenderStudyState();
}

class _RenderStudyState extends State<RenderStudy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: CustomScrollView(
        slivers: [
          SliverTopSection(
            child: TopSection(),
          ),
          TestSliver(
            child: Container(
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[300],
                  Colors.red,
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class TestSliver extends StatelessWidget {
  final Widget child;

  const TestSliver({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CloneSliverFillRemainingAndOverscroll(child: child);
  }
}

class CloneSliverFillRemainingAndOverscroll
    extends SingleChildRenderObjectWidget {
  const CloneSliverFillRemainingAndOverscroll({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  CloneRenderSliverFillRemainingAndOverscroll createRenderObject(
          BuildContext context) =>
      CloneRenderSliverFillRemainingAndOverscroll();
}

class CloneRenderSliverFillRemainingAndOverscroll
    extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a non-scrollable [RenderBox] which is
  /// sized to fit the remaining space plus any overscroll in the viewport.
  CloneRenderSliverFillRemainingAndOverscroll({RenderBox child})
      : super(child: child);

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // The remaining space in the viewportMainAxisExtent. Can be <= 0 if we have
    // scrolled beyond the extent of the screen.
    double extent =
        constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;

    print('$extent');

    // The maxExtent includes any overscrolled area. Can be < 0 if we have
    // overscroll in the opposite direction, away from the end of the list.
    double maxExtent =
        constraints.remainingPaintExtent - min(constraints.overlap, 0.0);

    if (child != null) {
      double childExtent;
      switch (constraints.axis) {
        case Axis.horizontal:
          childExtent = child.getMaxIntrinsicWidth(constraints.crossAxisExtent);
          break;
        case Axis.vertical:
          childExtent =
              child.getMaxIntrinsicHeight(constraints.crossAxisExtent);
          break;
      }

      // If the childExtent is greater than the computed extent, we want to use
      // that instead of potentially cutting off the child. This allows us to
      // safely specify a maxExtent.
      extent = max(extent, childExtent);
      // The extent could be larger than the maxExtent due to a larger child
      // size or overscrolling at the top of the scrollable (rather than at the
      // end where this sliver is).
      maxExtent = max(extent, maxExtent);
      child.layout(constraints.asBoxConstraints(
          minExtent: extent, maxExtent: maxExtent));
    }

    assert(
      extent.isFinite,
      'The calculated extent for the child of SliverFillRemaining is not finite. '
      'This can happen if the child is a scrollable, in which case, the '
      'hasScrollBody property of SliverFillRemaining should not be set to '
      'false.',
    );
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: extent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: min(maxExtent, constraints.remainingPaintExtent),
      maxPaintExtent: maxExtent,
      hasVisualOverflow: extent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    if (child != null) setChildParentData(child, constraints, geometry);
  }
}
