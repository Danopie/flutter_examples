import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSliver extends StatefulWidget {
  @override
  _CustomSliverState createState() => _CustomSliverState();
}

class _CustomSliverState extends State<CustomSliver> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              child: Placeholder(),
            ),
          ),
          SliverGap(100),
          SliverToBoxAdapter(
            child: Container(
              height: 1000,
              child: Placeholder(),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverGap extends SingleChildRenderObjectWidget {
  final double length;

  SliverGap(this.length);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverGap(length);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverGap renderObject) {
    renderObject.length = length;
  }
}

class RenderSliverGap extends RenderSliver {
  RenderSliverGap(this._length);

  double get length => _length;
  double _length;
  set length(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (_length == value) return;
    _length = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    geometry = SliverGeometry(
      scrollExtent: length,
      cacheExtent: calculateCacheOffset(constraints, from: 0.0, to: length),
      maxPaintExtent: length,
      paintExtent: calculatePaintOffset(constraints, from: 0.0, to: length),
      layoutExtent: calculatePaintOffset(constraints, from: 0.0, to: length),
    );
  }
}

class TestSliver extends SingleChildRenderObjectWidget {
  final Color color;

  TestSliver({this.color});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TestRenderSliver(color: color);
  }
}

class TestRenderSliver extends RenderSliver with RenderSliverHelpers {
  final Color color;

  TestRenderSliver({this.color});

  @override
  void performLayout() {
    print('$constraints');
    final originalMaxExtent = 200.0;
    final originalMinExtent = 50.0;
    final scrollValue = constraints.scrollOffset.clamp(0.0, 200.0);
    final paintExtent =
        ((originalMinExtent - originalMaxExtent) * (scrollValue) / 200.0) +
            originalMaxExtent;

    // final layoutExtent =
    //     paintExtent > 50.0?  :;

    geometry = SliverGeometry(
        scrollExtent: originalMaxExtent,
        paintExtent: paintExtent,
        layoutExtent: paintExtent,
        maxPaintExtent: originalMaxExtent,
        maxScrollObstructionExtent: paintExtent,
        cacheExtent: paintExtent);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
        Rect.fromPoints(
            offset,
            Offset(offset.dx + constraints.crossAxisExtent,
                offset.dy + geometry.paintExtent)),
        Paint()..color = color);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
  }
}

class DiagonalMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  final int childCount;

  DiagonalMultiChildLayoutDelegate(this.childCount);

  @override
  void performLayout(Size size) {
    for (int i = 0; i < childCount; i++) {
      if (hasChild(i)) {
        final childSize = layoutChild(i, BoxConstraints.loose(size));
        if (i == 0) {
          positionChild(i, Offset((size.width - childSize.width) / 2, 0));
        } else if (i == 1) {
          positionChild(
              i, Offset(size.width - childSize.width, size.height / 2));
        } else if (i == 2) {
          positionChild(
              i,
              Offset((size.width - childSize.width) / 2,
                  size.height - childSize.height));
        } else {
          positionChild(i, Offset(0, size.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRelayout(covariant DiagonalMultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class CenterChildLayoutDelegate extends SingleChildLayoutDelegate {
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset((size.width - childSize.width) / 2,
        (size.height - childSize.height) / 2);
  }

  @override
  bool shouldRelayout(covariant CenterChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class CloneSizedBox extends SingleChildRenderObjectWidget {
  final double width;
  final double height;

  const CloneSizedBox({Widget child, this.width, this.height})
      : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CloneRenderSizedBox(height: height, width: width);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant CloneRenderSizedBox renderObject) {
    renderObject.width = width;
    renderObject.height = height;
  }
}

class CloneRenderSizedBox extends RenderProxyBox {
  CloneRenderSizedBox({double width, double height}) {
    _width = width;
    _height = height;
  }

  double get width => _width;
  double _width;
  set width(double value) {
    assert(value != null);
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double get height => _height;
  double _height;
  set height(double value) {
    assert(value != null);
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    if (child != null) {
      child.layout(
          BoxConstraints.loose(Size(width, height)).enforce(constraints),
          parentUsesSize: true);
      size = child.size;
    } else {
      size = constraints.constrain(Size(width, height));
    }
  }
}
