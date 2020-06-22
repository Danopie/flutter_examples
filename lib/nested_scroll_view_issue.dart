import 'package:flutter/material.dart';

class NestedScrollViewIssueDemo extends StatefulWidget {
  @override
  _NestedScrollViewIssueDemoState createState() =>
      _NestedScrollViewIssueDemoState();
}

class _NestedScrollViewIssueDemoState extends State<NestedScrollViewIssueDemo> {
  final _controller = ScrollController();
  ScrollController innerScrollController;

  @override
  void initState() {
    _controller.addListener(() {
      print('offset: ${_controller.offset} maxScrollExtent: ${_controller.position.maxScrollExtent}');
      print('${_controller.positions}');
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          innerScrollController.animateTo(innerScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.decelerate);
        },
      ),
      body: Container(
        child: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.green,
                ),
              )
            ];
          },
          body: Builder(builder: (BuildContext context) {
            if(innerScrollController == null){
              innerScrollController = PrimaryScrollController.of(context);
            }
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: List<Widget>.generate(
                      20,
                          (index) => ListTile(
                        title: Text("Item $index"),
                      )),
                ),
              ),
            );
          },

          ),
        ),
      ),
    );
  }
}
