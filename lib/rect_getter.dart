import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:flutter/scheduler.dart';

class TestRectGetter extends StatefulWidget {
  @override
  _TestRectGetterState createState() => _TestRectGetterState();
}

class _TestRectGetterState extends State<TestRectGetter> {
  List<RectGetter> itemWidgets = List<RectGetter>();
  ScrollController controller;
  double _itemHeight = 40;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
//    controller.addListener(() {
//      print('ScrollController listener called');
//    });
//
//    SchedulerBinding.instance.addPostFrameCallback((duration) {
//      controller.position.addListener(() {
//        print('Scroll positions changed');
//      });
//    });

    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        _itemHeight = 80;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RectGetter in ListView"),
      ),
      body: ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          Widget element = RectGetter.defaultKey(
              child: Container(
            height: _itemHeight,
            child: ListTile(
              title: Text("Item no $index"),
            ),
          ));
          itemWidgets.insert(index, element);
          return element;
        },
        itemCount: 15,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        itemWidgets.forEach((widget) {
          Rect rect = widget.getRect();
          print(rect);
        });
      }),
    );
  }
}
