import 'package:flutter/material.dart';

class AnimatedListDemo extends StatefulWidget {
  @override
  _AnimatedListDemoState createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final items = List<int>.generate(3, (i) => i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: FadeInList(items: items)),
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

class FadeInList extends StatefulWidget {
  final List<int> items;

  const FadeInList({Key key, this.items}) : super(key: key);

  @override
  _FadeInListState createState() => _FadeInListState();
}

class _FadeInListState extends State<FadeInList> {
  static const kInsertDuration = Duration(milliseconds: 200);

  static const kRemoveDuration = Duration(milliseconds: 150);

  final _listKey = GlobalKey<AnimatedListState>();

  final scrollController = ScrollController();

  List<int> _oldList;

  @override
  void initState() {
    _oldList = List<int>.from(widget.items);
    super.initState();
  }

  @override
  void didUpdateWidget(FadeInList oldWidget) {
    checkAndAnimateDifferences();
    super.didUpdateWidget(oldWidget);
  }

  Future checkAndAnimateDifferences() async {
    print('-------------------\noldList:${_oldList}\nnewList:${widget.items}');
    if (widget.items == null || widget.items.isEmpty) {
      await _removeAllItems();
      _oldList.clear();
    } else if (_oldList.length != widget.items.length) {
      final lengthDifference = widget.items.length - _oldList.length;
      for (int i = 0; i < lengthDifference.abs(); i++) {
        if (lengthDifference >= 0) {
          await _insertItemAt(_oldList.length + i);
        } else {
          await _removeItemAt(_oldList.length - 1 - i);
        }
      }
    }
    _oldList = List<int>.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      key: _listKey,
      initialItemCount: _oldList.length,
      itemBuilder: (BuildContext context, int index, Animation animation) {
        return AnimatedItem(
          item: widget.items[index],
          animation: animation,
        );
      },
    );
  }

  Widget _buildRemovedItem(
      BuildContext context, Animation<double> animation, int item) {
    return AnimatedItem(
      item: item,
      animation: animation,
    );
  }

  Future<void> _insertItemAt(int index) async {
    _listKey.currentState.insertItem(index, duration: kInsertDuration);

    await Future.delayed(kInsertDuration);

    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: kInsertDuration, curve: Curves.decelerate);
  }

  Future<void> _removeItemAt(int index) async {
    print('_FadeInListState._removeItemAt: $index');
    final item = _oldList[index];

    _listKey.currentState.removeItem(index, (context, animation) {
      return _buildRemovedItem(context, animation, item);
    }, duration: kRemoveDuration);
    await Future.delayed(kRemoveDuration);
  }

  Future<void> _removeAllItems() async {
    final length = _oldList.length;
    for (int i = 0; i < length; i++) {
      await _removeItemAt(length - 1 - i);
    }
  }
}

class AnimatedItem extends StatelessWidget {
  final int item;
  final Animation<double> animation;

  const AnimatedItem({Key key, this.item, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0))
          .animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          child: Container(
            margin: EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Text("$item"),
          ),
        ),
      ),
    );
  }
}
