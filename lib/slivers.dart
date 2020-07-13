import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarSnapDemo extends StatefulWidget {
  @override
  _AppBarSnapDemoState createState() => _AppBarSnapDemoState();
}

class _AppBarSnapDemoState extends State<AppBarSnapDemo>
    with SingleTickerProviderStateMixin {
  ScrollController _controller = ScrollController();
  List<int> items = List<int>();

  @override
  void initState() {
    items = _getInitialList();
    _controller.addListener(() {
      if (_controller.offset > _controller.position.maxScrollExtent - 100) {
        loadMore();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: HeaderDelegate(this, _controller),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              setState(() {
                items = _getInitialList();
              });
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text("Item ${items[index]}"),
                );
              },
              childCount: items.length,
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getInitialList() {
    return List<int>.generate(10, (index) => index);
  }

  void loadMore() {
    setState(() {
      items.addAll(_getInitialList());
    });
  }
}

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final TickerProvider vsync;
  final ScrollController scrollController;

  HeaderDelegate(this.vsync, this.scrollController);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ScrollViewSnapper(
      child: Placeholder(),
      maxHeight: 148,
      minHeight: 80,
      controller: scrollController,
    );
  }

  @override
  double get maxExtent => 148;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ScrollViewSnapper extends StatefulWidget {
  const ScrollViewSnapper(
      {Key key, this.child, this.maxHeight, this.minHeight, this.controller})
      : super(key: key);

  final Widget child;
  final double maxHeight;
  final double minHeight;
  final ScrollController controller;

  @override
  _ScrollViewSnapperState createState() => _ScrollViewSnapperState();
}

class _ScrollViewSnapperState extends State<ScrollViewSnapper> {
  ScrollPosition _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position != null)
      _position.isScrollingNotifier.removeListener(_isScrollingListener);
    _position = Scrollable.of(context)?.position;
    if (_position != null)
      _position.isScrollingNotifier.addListener(_isScrollingListener);
  }

  @override
  void dispose() {
    if (_position != null)
      _position.isScrollingNotifier.removeListener(_isScrollingListener);
    super.dispose();
  }

  void _isScrollingListener() {
    if (_position == null) return;

    if (!_position.isScrollingNotifier.value) {
      final heightDelta = widget.maxHeight - widget.minHeight;
      print(
          'Stop scrolling: offset at ${_position.pixels} comparing to ${widget.maxHeight - widget.minHeight}');
      if (_position.pixels > 0 && _position.pixels < heightDelta) {
        print('Start snap');
        double snapDistance;
        if (_position.pixels / heightDelta > 0.5) {
          snapDistance = heightDelta;
        } else {
          snapDistance = 0;
        }
        widget.controller.animateTo(snapDistance,
            duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
