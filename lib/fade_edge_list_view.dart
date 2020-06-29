import 'dart:ui';

import 'package:flutter/material.dart';

class FadingEdgeListView extends StatefulWidget {
  @override
  _FadingEdgeListViewState createState() => _FadingEdgeListViewState();
}

class _FadingEdgeListViewState extends State<FadingEdgeListView> {
  final items = List<String>.generate(50, (index) => "Item $index");
  final controller = ScrollController();
  int latestIndex;

  @override
  void initState() {
    super.initState();
    controller.addListener((){
      print('offset ${controller.offset}');
      print('viewportDimension ${controller.position.viewportDimension}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400,
        child: Stack(
          children: <Widget>[
            ListView.builder(
              controller: controller,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  if (index == 5) {
                    return Opacity(
                      opacity: 0.4,
                      child: ListTile(
                        title: Text(items[index]),
                      ),
                    );
                  } else if(index == 6){
                    return Opacity(
                      opacity: 0.2,
                      child: ListTile(
                        title: Text(items[index]),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(items[index]),
                    );
                  }
                }),
//            Align(
//              alignment: Alignment.bottomCenter,
//              child: BackdropFilter(
//                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
//                child: Container(
//                  height: 100,
//                  decoration: new BoxDecoration(
//                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
//                  ),
//                ),
//              ),
//            )
          ],
        ),
      ),
    );
  }
}

class FadingItem extends StatefulWidget {
  @override
  _FadingItemState createState() => _FadingItemState();
}

class _FadingItemState extends State<FadingItem> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}

