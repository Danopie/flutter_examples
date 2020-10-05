import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class VinIDHomeAppBarDemo extends StatefulWidget {
  @override
  _VinIDHomeAppBarDemoState createState() => _VinIDHomeAppBarDemoState();
}

class BackgroundCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final clipHeight = size.height * 4 / 5;
    final heightOffset = 60;

    final path = Path();
    path.lineTo(0, clipHeight);
    path.quadraticBezierTo(
        size.width / 2, clipHeight + heightOffset, size.width, clipHeight);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _VinIDHomeAppBarDemoState extends State<VinIDHomeAppBarDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverTopSection(
          child: TopSection(),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                );
              },
              childCount: 12,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8)),
                );
              },
              childCount: 12,
            ),
          ),
        ),
      ],
    ));
  }
}

class SliverTopSection extends SingleChildRenderObjectWidget {
  SliverTopSection({Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverTopSection();
  }
}

class RenderSliverTopSection extends RenderSliverSingleBoxAdapter {
  RenderSliverTopSection({RenderBox child}) {
    this.child = child;
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
    } else {
      final childExtent = kTopHeight;

      // If RenderSliver is on top-most, constraints.overlap will reflect overscroll value, which is negative
      final boxHeightWithOverlap = childExtent + constraints.overlap.abs();

      // Force child with the height that includes the overlap distance
      final boxConstraints = constraints.asBoxConstraints().copyWith(
          maxHeight: boxHeightWithOverlap, minHeight: boxHeightWithOverlap);
      child.layout(boxConstraints);

      final childPaintSize =
          calculatePaintOffset(constraints, from: 0.0, to: childExtent);
      final cacheExtent =
          calculateCacheOffset(constraints, from: 0.0, to: childExtent);
      //
      // print('ChildExtent: $childExtent');
      // print('TotalHeight: $boxHeightWithOverlap');
      // print('Constraints for child is $boxConstraints');
      // print('ChildPaintSize: $childPaintSize CacheExtent: $cacheExtent');
      // print('---------------------------------------');

      geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: childPaintSize,
        maxPaintExtent: childPaintSize,
        cacheExtent: cacheExtent,
        paintOrigin: constraints.overlap,
        hitTestExtent: childPaintSize,
        hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
      setChildParentData(child, constraints, geometry);
    }
  }
}

final kTopHeight = 280.0;

class TopSection extends StatelessWidget {
  const TopSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          child: Stack(children: [
            Positioned.fill(child: VinIdBackground()),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFront(context, kTopHeight)),
          ]),
        );
      },
    );
  }

  Widget _buildFront(BuildContext context, double maxHeight) {
    return HookBuilder(
      builder: (context) {
        final pageControllerState = useState<PageController>(PageController(
          initialPage: 0,
          viewportFraction: 0.9,
        ));

        return Container(
          height: maxHeight,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 32,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                    Container(
                      width: 12,
                    ),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(32)),
                    )
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: pageControllerState.value,
                  children: List<Widget>.generate(
                      2, (index) => _buildBannerInfoBlock(index)),
                ),
              ),
              Container(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  _buildBannerInfoBlock(int index) {
    final isFirst = index == 0;
    return Container(
      margin: EdgeInsets.only(right: isFirst ? 8 : 0, left: !isFirst ? 8 : 0),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class VinIdBackground extends StatelessWidget {
  const VinIdBackground({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BackgroundCurveClipper(),
      child: Image.network(
        "https://img.freepik.com/free-psd/abstract-background-design_1297-82.jpg?size=626&ext=jpg",
        fit: BoxFit.cover,
      ),
    );
  }
}
