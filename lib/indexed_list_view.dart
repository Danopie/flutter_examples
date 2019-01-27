import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

class TestIndexListView extends StatefulWidget {
  @override
  _TestIndexListViewState createState() => _TestIndexListViewState();
}

class _TestIndexListViewState extends State<TestIndexListView> {
  IndexedScrollController controller;
  double _itemHeight = 50;

  @override
  void initState() {
    super.initState();

    controller = IndexedScrollController();

    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        _itemHeight = 90;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Indexed in ListView"),
      ),
      body: IndexedListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          return Container(
            height: _itemHeight,
            child: ListTile(
              title: Text("Item $index"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        controller.jumpToIndex(10);
      }),
    );
  }
}
