import 'dart:math';

import 'package:flutter/material.dart';

class TabViewTest extends StatefulWidget {
  @override
  _TabViewTestState createState() => _TabViewTestState();
}

class _TabViewTestState extends State<TabViewTest>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  final tabs = ['1', '2', '3'];
  Color backgroundColor;
  int count = 0;

  @override
  void initState() {
    _controller = TabController(length: tabs.length, vsync: this);
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        print(
            '_TabViewTestState.controller: move to tab ${_controller.index + 1}');
        setState(() {
          count++;
        });
      }
    });
    backgroundColor = Colors.blue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          height: 54,
          child: TabBar(
            tabs: _buildTabs(),
            controller: _controller,
          ),
        ),
        Expanded(
          child: TabBarView(
            children: _buildTabViews(),
            controller: _controller,
          ),
        )
      ]),
    );
  }

  _buildTabViews() {
    print('_TabViewTestState._buildTabViews');
    final widgets = List<Widget>();
    tabs.forEach((tab) {
      widgets.add(TabView(
        tab: tab,
      ));
    });
    return widgets;
  }

  _buildTabs() {
    print('_TabViewTestState._buildTabs');
    final widgets = List<Widget>();
    tabs.forEach((tab) {
      widgets.add(Tab(
        child: Text("Tab $tab.$count"),
      ));
    });
    return widgets;
  }
}

class TabView extends StatefulWidget {
  final String tab;

  TabView({Key key, this.tab}) : super(key: key) {
    print('TabView.TabView constructor');
  }

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView>
    with AutomaticKeepAliveClientMixin<TabView> {
  Color color;
  Random random = Random();
  @override
  void initState() {
    super.initState();
    print('_TabViewState.initState of tab ${widget.tab}');
    color = Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: 100,
        width: 100,
        color: color,
        child: Text("TabView ${widget.tab}"),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
