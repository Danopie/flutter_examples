import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter/material.dart';

class AnimatedListDemo extends StatefulWidget {
  @override
  _AnimatedListDemoState createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final items = List<int>.generate(3, (i) => i);

  @override
  Widget build(BuildContext context) {
    final newItems = List.unmodifiable(items).cast<int>();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ImplicitlyAnimatedList(
              items: newItems,
              builder: (context, index) {
                return ItemCard(
                  item: newItems[index],
                );
              },
              insertAnimationBuilder: (context, animation, child) =>
                  AnimatedItem(
                child: child,
                animation: animation,
              ),
              removeAnimationBuilder: (context, animation, child) =>
                  AnimatedItem(
                child: child,
                animation: animation,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  child: Text("Add"),
                  onPressed: () {
                    setState(() {
                      items.add(items.length);
                    });
                  },
                ),
              ),
              Expanded(
                child: RaisedButton(
                  child: Text("Add 2 items"),
                  onPressed: () async {
                    setState(() {
                      final length = items.length;
                      items.addAll([length, length + 1]);
                    });
                  },
                ),
              ),
              Expanded(
                child: RaisedButton(
                  child: Text("Remove"),
                  onPressed: () {
                    setState(() {
                      items.removeLast();
                    });
                  },
                ),
              ),
              Expanded(
                child: RaisedButton(
                  child: Text("Remove 2 items"),
                  onPressed: () async {
                    setState(() {
                      items.removeRange(items.length - 2, items.length);
                    });
                  },
                ),
              ),
              Expanded(
                child: RaisedButton(
                  child: Text("Remove all"),
                  onPressed: () async {
                    setState(() {
                      items.clear();
                    });
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

typedef ImplicitlyWidgetBuilder<T> = Widget Function(
    BuildContext context, T item);
typedef AnimatedImplicitlyWidgetBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget child);

class ImplicitlyAnimatedList extends StatefulWidget {
  final List<int> items;
  final ImplicitlyWidgetBuilder<int> builder;
  final AnimatedImplicitlyWidgetBuilder insertAnimationBuilder;
  final AnimatedImplicitlyWidgetBuilder removeAnimationBuilder;

  const ImplicitlyAnimatedList({
    Key key,
    this.items,
    this.builder,
    this.insertAnimationBuilder,
    this.removeAnimationBuilder,
  }) : super(key: key);

  @override
  _ImplicitlyAnimatedListState createState() => _ImplicitlyAnimatedListState();
}

class _ImplicitlyAnimatedListState extends State<ImplicitlyAnimatedList>
    implements ListUpdateCallback {
  static const kInsertDuration = Duration(milliseconds: 200);

  static const kRemoveDuration = Duration(milliseconds: 150);

  final _listKey = GlobalKey<AnimatedListState>();

  final scrollController = ScrollController();

  AnimatedImplicitlyWidgetBuilder oldRemoveAnimationBuilder;

  List<int> oldList;

  ImplicitlyWidgetBuilder<int> oldBuilder;

  @override
  void didUpdateWidget(ImplicitlyAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldList = oldWidget.items;
    final diffResult = calculateListDiff<int>(oldList, widget.items);
    oldRemoveAnimationBuilder = oldWidget.removeAnimationBuilder;
    oldBuilder = oldWidget.builder;
    diffResult.dispatchUpdatesTo(this);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      key: _listKey,
      initialItemCount: 3,
      itemBuilder: (BuildContext context, int index, Animation animation) =>
          widget.insertAnimationBuilder(
        context,
        animation,
        widget.builder(context, index),
      ),
    );
  }

  Future<void> _insertItemAt(int index) async {
    _listKey.currentState.insertItem(index, duration: kInsertDuration);

    await Future.delayed(kInsertDuration);

    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: kInsertDuration, curve: Curves.decelerate);
  }

  Future<void> _removeItemAt(int index) async {
    print('_FadeInListState._removeItemAt: $index in list $oldList');
    final oldItem = oldList[index];

    _listKey.currentState.removeItem(index, (context, animation) {
      return oldRemoveAnimationBuilder(
          context, animation, oldBuilder(context, oldItem));
    }, duration: kRemoveDuration);
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

  final int item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Text("$item"),
      ),
    );
  }
}
