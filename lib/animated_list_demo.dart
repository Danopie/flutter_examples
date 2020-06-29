import 'dart:math';

import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/async/nanoid.dart';

class AnimatedListDemo extends StatefulWidget {
  @override
  _AnimatedListDemoState createState() => _AnimatedListDemoState();
}

class Data {
  int index;
  String id;

  Data(this.index, this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Data &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          id == other.id;

  @override
  int get hashCode => index.hashCode ^ id.hashCode;
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  List<Data> data;
  bool isLoading = false;

  @override
  void initState() {
    requestLoadData();
    super.initState();
  }

  void requestLoadData() {
    if (isLoading) return;
    isLoading = true;
    loadData().then((value) {
      setState(() {
        if (data == null) data = List<Data>();
        data.addAll(value);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              final offset = notification.metrics.pixels;
              final maxOffset = notification.metrics.maxScrollExtent;
              if (offset > maxOffset - 200) {
                requestLoadData();
              }
              return false;
            },
            child: ImplicitlyAnimatedList<Data>(
              items: data == null ? data : List.unmodifiable(data).cast<Data>(),
              builder: (context, dynamic item) => ItemCard(
                item: item,
              ),
              insertAnimationBuilder: (context, animation, child) =>
                  AnimatedItem(
                child: child,
                animation: animation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Data>> loadData() async {
    await Future.delayed(Duration(seconds: 1));
    final count = Random().nextInt(2) + 10;
    final data = List<Data>();

    for (int i = 0; i < count; i++) {
      data.add(Data(i, await nanoid()));
    }
    return data;
  }
}

class AnimatedItem extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const AnimatedItem({Key key, this.child, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0))
          .animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Data item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Text("Id: ${item.id} -- Index: ${item.index}"),
      ),
    );
  }
}

/// ------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------

typedef ImplicitlyWidgetBuilder<T> = Widget Function(
    BuildContext context, T item);
typedef AnimatedImplicitlyWidgetBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget child);

class ImplicitlyAnimatedList<T> extends StatefulWidget {
  static Widget buildDefaultLoading(BuildContext context) {
    return const Center(
      child: const CircularProgressIndicator(),
    );
  }

  static Widget buildDefaultEmpty(BuildContext context) => Container();

  final List<T> items;
  final ImplicitlyWidgetBuilder<T> builder;
  final AnimatedImplicitlyWidgetBuilder insertAnimationBuilder;
  final AnimatedImplicitlyWidgetBuilder removeAnimationBuilder;
  final ScrollPhysics physics;
  final ScrollController controller;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder emptyBuilder;

  const ImplicitlyAnimatedList({
    Key key,
    this.items,
    this.builder,
    this.insertAnimationBuilder,
    this.removeAnimationBuilder,
    this.physics,
    this.controller,
    this.insertAnimationDuration = const Duration(milliseconds: 200),
    this.removeAnimationDuration = const Duration(milliseconds: 150),
    this.loadingBuilder = buildDefaultLoading,
    this.emptyBuilder = buildDefaultEmpty,
  }) : super(key: key);

  @override
  _ImplicitlyAnimatedListState<T> createState() =>
      _ImplicitlyAnimatedListState<T>();
}

class _ImplicitlyAnimatedListState<T> extends State<ImplicitlyAnimatedList> {
  final _listKey = GlobalKey<AnimatedListState>();

  ScrollController scrollController;

  AnimatedImplicitlyWidgetBuilder oldRemoveAnimationBuilder;

  List<T> oldList;

  ImplicitlyWidgetBuilder<T> oldBuilder;

  bool firstInsert = true;

  @override
  void initState() {
    scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  @override
  void didUpdateWidget(ImplicitlyAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldList = oldWidget.items;
    checkAndAnimateItems(oldWidget);
  }

  void checkAndAnimateItems(ImplicitlyAnimatedList oldWidget) {
    DiffResultListUpdateDelegate(
      firstInsert: firstInsert,
      insertAnimationDuration: widget.insertAnimationDuration,
      removeAnimationDuration: oldWidget.removeAnimationDuration,
      listKey: _listKey,
      oldBuilder: oldWidget.builder,
      removeAnimationBuilder:
          oldWidget.removeAnimationBuilder ?? oldWidget.insertAnimationBuilder,
      oldList: oldList ?? List<T>(),
      newList: widget.items ?? List<T>(),
    ).execute();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedList(
          controller: scrollController,
          physics: widget.physics,
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          key: _listKey,
          initialItemCount: 0,
          itemBuilder: (BuildContext context, int index, Animation animation) {
            return widget.insertAnimationBuilder(
              context,
              animation,
              widget.builder(context, widget.items[index]),
            );
          },
        ),
        if (widget.items == null)
          widget.loadingBuilder(context)
        else if (widget.items.isEmpty)
          widget.emptyBuilder(context),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>(
        'insertAnimationDuration', widget.insertAnimationDuration));
    properties.add(DiagnosticsProperty<Duration>(
        'removeAnimationDuration', widget.removeAnimationDuration));
    properties.add(
        DiagnosticsProperty<ScrollPhysics>('scrollPhysics', widget.physics));
  }
}

class DiffResultListUpdateDelegate<T> implements ListUpdateCallback {
  final bool firstInsert;
  final GlobalKey<AnimatedListState> listKey;
  final AnimatedImplicitlyWidgetBuilder removeAnimationBuilder;
  final ImplicitlyWidgetBuilder<T> oldBuilder;
  final List<T> oldList;
  final List<T> newList;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;

  DiffResultListUpdateDelegate({
    this.firstInsert,
    this.listKey,
    this.removeAnimationBuilder,
    this.oldBuilder,
    this.oldList,
    this.insertAnimationDuration,
    this.removeAnimationDuration,
    this.newList,
  });

  Future<void> execute() {
    calculateListDiff<T>(oldList, newList).dispatchUpdatesTo(this);
  }

  Future<void> _insertItemAt(int index) async {
    listKey.currentState.insertItem(index, duration: insertAnimationDuration);

    await Future.delayed(insertAnimationDuration);

//    scrollController.animateTo(scrollController.position.maxScrollExtent,
//        duration: widget.insertAnimationDuration, curve: Curves.decelerate);
  }

  Future<void> _removeItemAt(int index) async {
    print('_FadeInListState._removeItemAt: $index in list $oldList');
    final oldItem = oldList[index];

    listKey.currentState.removeItem(
      index,
      (context, animation) {
        return removeAnimationBuilder(
          context,
          animation,
          oldBuilder(context, oldItem),
        );
      },
      duration: removeAnimationDuration,
    );
  }

  @override
  void onChanged(int position, int count, Object payload) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onInserted(int position, int count) async {
    for (int i = 0; i < count; i++) {
      if (firstInsert) {
        await _insertItemAt(position + i);
      } else {
        _insertItemAt(position + i);
      }
    }
  }

  @override
  Future<void> onMoved(int fromPosition, int toPosition) async {
    await _removeItemAt(fromPosition);
    await _insertItemAt(toPosition);
  }

  @override
  Future<void> onRemoved(int position, int count) async {
    for (int i = count - 1; i >= 0; i--) {
      _removeItemAt(position + i);
    }
  }
}
