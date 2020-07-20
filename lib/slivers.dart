import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart';

class AppBarSnapDemo extends StatefulWidget {
  @override
  _AppBarSnapDemoState createState() => _AppBarSnapDemoState();
}

class _AppBarSnapDemoState extends State<AppBarSnapDemo>
    with SingleTickerProviderStateMixin {
  ScrollController _controller = ScrollController();
  final controller = ItemListController();

  @override
  void initState() {
    controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<ItemListController, ItemListState>(
      create: (_) => controller,
      child: Builder(
        builder: (context) {
          final state = context.watch<ItemListState>();
          final items = state.items;
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: AwesomeListView(
                    controller: _controller,
                    onRefresh: context.watch<ItemListController>().onRefresh,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(12),
                        height: 60,
                        color: Colors.green,
                        child: ListTile(
                          title: Text("Item $index"),
                        ),
                      );
                    },
                    itemCount: items?.length,
                    emptyBuilder: (_) => Center(
                      child: Text(state.id == ItemListState.Loading
                          ? "Loading"
                          : "Empty"),
                    ),
                    onPagingLoad: context.watch<ItemListController>().loadMore,
                    headerBuilder: (context, shrinkOffset, overlapsContent) =>
                        Placeholder(),
                    headerMaxExtent: 148,
                    headerMinExtent: 80,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ItemListState {
  static const String Loading = "Loading";
  static const String DoneLoading = "DoneLoading";

  final String id;
  final List<int> items;

  const ItemListState({
    @required this.id,
    this.items,
  });

  ItemListState copyWith({
    String id,
    List<int> items,
  }) {
    return new ItemListState(
      id: id ?? this.id,
      items: items ?? this.items,
    );
  }
}

class ItemListController extends StateNotifier<ItemListState> {
  ItemListController() : super(ItemListState(id: ItemListState.Loading));

  Future<void> init() async {
    await onRefresh();
  }

  List<int> _getInitialList() {
    return List<int>.generate(2, (index) => index);
  }

  Future<void> loadMore() async {
    print('ItemListController.loadMore');
    if (state.items != null && state.items.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 200));
      final newList = List.of(state.items)..addAll(_getInitialList());

      state = state.copyWith(items: newList);
    }
  }

  Future<void> onRefresh() async {
    print('ItemListController.onRefresh');
    await Future.delayed(Duration(seconds: 1));
    state =
        state.copyWith(id: ItemListState.DoneLoading, items: _getInitialList());
  }
}

class AwesomeListView<T> extends StatefulWidget {
  final ScrollController controller;
  final Function onRefresh;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final WidgetBuilder emptyBuilder;
  final bool pinned;
  final bool floating;
  final Function onPagingLoad;
  final ScrollHeaderBuilder headerBuilder;
  final double headerMaxExtent;
  final double headerMinExtent;
  final double pagingTriggerOffset;

  const AwesomeListView({
    Key key,
    this.controller,
    this.onRefresh,
    this.itemBuilder,
    this.itemCount,
    this.emptyBuilder,
    this.pinned = true,
    this.floating = false,
    this.onPagingLoad,
    this.headerBuilder,
    this.headerMaxExtent,
    this.headerMinExtent,
    this.pagingTriggerOffset = 100,
  }) : super(key: key);

  @override
  _AwesomeListViewState createState() => _AwesomeListViewState();
}

class _AwesomeListViewState extends State<AwesomeListView> {
  final Throttling thr = new Throttling(duration: Duration(milliseconds: 500));
  ScrollController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {

        final userReachingMaxExtent = scrollNotification.metrics.pixels >
            scrollNotification.metrics.maxScrollExtent -
                widget.pagingTriggerOffset;

        final userIsScrollingForward =
            _controller.position.userScrollDirection == ScrollDirection.reverse;

        if (userReachingMaxExtent && userIsScrollingForward) {
          if (widget.onPagingLoad != null) {
            thr.throttle(() {
              widget.onPagingLoad();
            });
          }
          return true;
        }
        return false;
      },
      child: RefreshIndicatorIfAndroid(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          controller: _controller,
          physics: AlwaysScrollableScrollPhysics(
              parent: Theme.of(context).platform == TargetPlatform.iOS
                  ? CustomBouncingScrollPhysics()
                  : CustomClampingScrollPhysics()),
          slivers: <Widget>[
            if (widget.headerBuilder != null)
              SliverPersistentHeader(
                pinned: widget.pinned,
                floating: widget.floating,
                delegate: _ScrollHeaderDelegate(
                  _controller,
                  widget.headerBuilder,
                  widget.headerMaxExtent,
                  widget.headerMinExtent,
                ),
              ),
            if (Theme.of(context).platform == TargetPlatform.iOS &&
                widget.onRefresh != null)
              CupertinoSliverRefreshControl(
                onRefresh: widget.onRefresh,
              ),
            if (widget.itemCount != null && widget.itemCount > 0)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  widget.itemBuilder,
                  childCount: widget.itemCount,
                ),
              )
            else
              SliverFillRemaining(
                child: widget.emptyBuilder(context),
                hasScrollBody: false,
              ),
          ],
        ),
      ),
    );
  }
}

class RefreshIndicatorIfAndroid extends StatelessWidget {
  final Widget child;
  final Function onRefresh;

  const RefreshIndicatorIfAndroid({Key key, this.child, this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android &&
        onRefresh != null) {
      return RefreshIndicator(
        child: child,
        onRefresh: onRefresh,
      );
    } else {
      return child;
    }
  }
}

typedef ScrollHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class _ScrollHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ScrollController scrollController;
  final ScrollHeaderBuilder headerBuilder;
  final double headerMaxExtent;
  final double headerMinExtent;

  _ScrollHeaderDelegate(
    this.scrollController,
    this.headerBuilder,
    this.headerMaxExtent,
    this.headerMinExtent,
  );

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ScrollViewSnapper(
      child: headerBuilder(context, shrinkOffset, overlapsContent),
      maxHeight: 148,
      minHeight: 80,
      controller: scrollController,
    );
  }

  @override
  double get maxExtent => headerMaxExtent;

  @override
  double get minExtent => headerMinExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ScrollViewSnapper extends StatefulWidget {
  const ScrollViewSnapper({
    Key key,
    this.child,
    this.maxHeight,
    this.minHeight,
    this.controller,
  }) : super(key: key);

  final Widget child;
  final double maxHeight;
  final double minHeight;
  final ScrollController controller;

  @override
  _ScrollViewSnapperState createState() => _ScrollViewSnapperState();
}

class _ScrollViewSnapperState extends State<ScrollViewSnapper>
    with TickerProviderStateMixin {
  ScrollPosition _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position != null)
      _position.isScrollingNotifier.removeListener(_isScrollingListener);
    _position = Scrollable.of(context)?.position;
    if (_position != null)
      _position.isScrollingNotifier.addListener(_isScrollingListener);

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            widget.controller.jumpTo(_animation.value);
          });
  }

  @override
  void dispose() {
    if (_position != null)
      _position.isScrollingNotifier.removeListener(_isScrollingListener);

    super.dispose();
  }

  Animation<double> _animation;
  AnimationController _animationController;

  Future<void> _isScrollingListener() async {
    if (_position == null) return;

    if (!_position.isScrollingNotifier.value &&
        !(_position.activity is HoldScrollActivity)) {
      final heightDelta = widget.maxHeight - widget.minHeight;

      if (_position.pixels >= 0 && _position.pixels < heightDelta) {
        double snapOffset;
        if (_position.pixels / heightDelta > 0.5) {
          snapOffset = heightDelta;
        } else {
          snapOffset = 0;
        }

        if (_position.pixels != snapOffset) {
          _animation = _animationController.drive(
              Tween<double>(begin: _position.pixels, end: snapOffset)
                  .chain(CurveTween(curve: Curves.easeIn)));

          _animationController.forward(from: 0.0);
        }
      }
    } else {
      _animationController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CustomClampingScrollPhysics extends ClampingScrollPhysics {
  CustomClampingScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  ClampingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomClampingScrollPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    } // underscroll

    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      if (position.maxScrollExtent == 0 && value > 10) {
        return value - position.pixels;
      }
    } // overscroll

    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    } // hit top edge

    return 0.0;
  }
}

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
  CustomBouncingScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomBouncingScrollPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      if (position.maxScrollExtent == 0 && value > 10) {
        return value - position.pixels;
      }
    }

    return 0.0;
  }
}

class Throttling {
  Duration _duration;
  Duration get duration => this._duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    this._duration = value;
  }

  bool _isReady = true;
  bool get isReady => isReady;
  Future<void> get _waiter => Future.delayed(this._duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC =
      new StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        this._duration = duration ?? Duration(seconds: 1) {
    this._stateSC.sink.add(true);
  }

  dynamic throttle(Function func) {
    if (!this._isReady) return null;
    this._stateSC.sink.add(false);
    this._isReady = false;
    _waiter
      ..then((_) {
        this._isReady = true;
        this._stateSC.sink.add(true);
      });
    return Function.apply(func, []);
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      this._stateSC.stream.listen(onData);

  dispose() {
    this._stateSC.close();
  }
}
