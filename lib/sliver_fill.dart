import 'package:flutter/material.dart';

class SliverFillTest extends StatefulWidget {
  @override
  _SliverFillTestState createState() => _SliverFillTestState();
}

class _SliverFillTestState extends State<SliverFillTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedSection(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                height: 50,
                width: 100,
                color: Colors.green,
                margin: EdgeInsets.all(12),
              ),
              childCount: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class PinnedSection extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.blue,
    );
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
