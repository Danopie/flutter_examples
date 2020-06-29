import 'package:flutter/material.dart';

class TestReorderableListView extends StatefulWidget {
  @override
  _TestReorderableListViewState createState() =>
      _TestReorderableListViewState();
}

class _TestReorderableListViewState extends State<TestReorderableListView> {
  final list = ['a', 'b', 'c'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ReorderableListView(
        children: list
            .map((item) => ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                ))
            .toList(),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String element = list.removeAt(oldIndex);
            list.insert(newIndex, element);
          });
        },
      ),
    );
  }
}
