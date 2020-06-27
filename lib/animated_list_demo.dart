import 'dart:math';

import 'package:diffutil_dart/diffutil.dart';
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
  List<Data> data = List<Data>();
  bool isLoading = false;

  @override
  void initState() {
    requestLoadData();
    super.initState();
  }

  void requestLoadData() {
    if (isLoading) return;
    isLoading = true;
    print('_AnimatedListDemoState.requestLoadData');
    loadData().then((value) {
      setState(() {
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
              if (offset > maxOffset - 100) {
                requestLoadData();
              }
              return false;
            },
            child: ImplicitlyAnimatedList<Data>(
              items: List.unmodifiable(data).cast<Data>(),
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
          if (data.isEmpty) Center(child: CircularProgressIndicator()),
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

typedef ImplicitlyWidgetBuilder<T> = Widget Function(
    BuildContext context, T item);
typedef AnimatedImplicitlyWidgetBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget child);

class ImplicitlyAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final ImplicitlyWidgetBuilder<T> builder;
  final AnimatedImplicitlyWidgetBuilder insertAnimationBuilder;
  final AnimatedImplicitlyWidgetBuilder removeAnimationBuilder;
  final ScrollPhysics physics;
  final ScrollController controller;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;

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
  }) : super(key: key);

  @override
  _ImplicitlyAnimatedListState<T> createState() =>
      _ImplicitlyAnimatedListState<T>();
}

class _ImplicitlyAnimatedListState<T> extends State<ImplicitlyAnimatedList>
    implements ListUpdateCallback {
  final _listKey = GlobalKey<AnimatedListState>();

  ScrollController scrollController;

  AnimatedImplicitlyWidgetBuilder oldRemoveAnimationBuilder;

  List<T> oldList;

  ImplicitlyWidgetBuilder<T> oldBuilder;

  @override
  void initState() {
    scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  @override
  void didUpdateWidget(ImplicitlyAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldList = oldList == null ? List<T>() : oldWidget.items;
    checkAndAnimateItems(oldWidget);
  }

  void checkAndAnimateItems(ImplicitlyAnimatedList oldWidget) {
    oldRemoveAnimationBuilder =
        oldWidget.removeAnimationBuilder ?? oldWidget.insertAnimationBuilder;
    oldBuilder = oldWidget.builder;

    calculateListDiff<T>(oldList, widget.items).dispatchUpdatesTo(this);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
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
    );
  }

  Future<void> _insertItemAt(int index) async {
    _listKey.currentState
        .insertItem(index, duration: widget.insertAnimationDuration);

    await Future.delayed(widget.insertAnimationDuration);

//    scrollController.animateTo(scrollController.position.maxScrollExtent,
//        duration: widget.insertAnimationDuration, curve: Curves.decelerate);
  }

  Future<void> _removeItemAt(int index) async {
    print('_FadeInListState._removeItemAt: $index in list $oldList');
    final oldItem = oldList[index];

    _listKey.currentState.removeItem(
      index,
      (context, animation) {
        return oldRemoveAnimationBuilder(
          context,
          animation,
          oldBuilder(context, oldItem),
        );
      },
      duration: widget.removeAnimationDuration,
    );
  }

  @override
  void onChanged(int position, int count, Object payload) async {
    print('_FadeInListState.onChanged: $position $count');
  }

  @override
  Future<void> onInserted(int position, int count) async {
    print('_ImplicitlyAnimatedListState.onInserted');
    for (int i = 0; i < count; i++) {
      await _insertItemAt(position + i);
    }
  }

  @override
  Future<void> onMoved(int fromPosition, int toPosition) async {
    print('_ImplicitlyAnimatedListState.onMoved');
    await _removeItemAt(fromPosition);
    await _insertItemAt(toPosition);
  }

  @override
  Future<void> onRemoved(int position, int count) async {
    print(
        '_ImplicitlyAnimatedListState.onRemoved: at $position for $count items');
    for (int i = count - 1; i >= 0; i--) {
      _removeItemAt(position + i);
    }
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
