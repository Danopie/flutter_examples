import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestNavigator extends StatefulWidget {
  @override
  _TestNavigatorState createState() => _TestNavigatorState();
}

class _TestNavigatorState extends State<TestNavigator> {
  final tabs = ['A', 'B', 'C'];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: tabs
              .map((tab) => BottomNavigationBarItem(
                  title: Text(tab),
                  icon: Icon(Icons.train),
                  activeIcon: Icon(Icons.input)))
              .toList()),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs
              .map((tab) => RootPage(
                    name: tab,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  final String name;

  const RootPage({Key key, this.name}) : super(key: key);
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  BuildContext _childContext;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
//        print('onPop: ${Navigator.of(_childContext)}');
        Navigator.of(_childContext).pop();
        return false;
      },
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              widget.name,
              style: TextStyle(fontSize: 20),
            ),
            margin: EdgeInsets.symmetric(vertical: 15),
          ),
          Expanded(
            child: Navigator(
              initialRoute: '/',
              onGenerateRoute: (RouteSettings settings) {
                return CupertinoPageRoute(
                  settings: settings,
                  builder: (BuildContext context) {
//                    print('assign: ${Navigator.of(context)}');
                    _childContext ??= context;
                    switch (settings.name) {
                      case '/':
                        return Page(
                          name: "/",
                        );
                      case '/list':
                        return Page(
                          name: "/list",
                        );
                      case '/text':
                        return Page(
                          name: "/text",
                        );
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class Page extends StatefulWidget {
  final String name;

  const Page({Key key, this.name}) : super(key: key);
  @override
  _PageState createState() => _PageState();
}

int next(int min, int max) => min + Random().nextInt(max - min);

class _PageState extends State<Page> {
  Color color;
  @override
  void initState() {
    color = ColorTween(begin: Colors.blue, end: Colors.orange)
        .lerp(next(0, 10).toDouble() / 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: color,
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 20),
              ),
              margin: EdgeInsets.symmetric(vertical: 15),
            ),
            RaisedButton(
              child: Text('/'),
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
            ),
            RaisedButton(
              child: Text('/list'),
              onPressed: () {
                Navigator.of(context).pushNamed('/list');
              },
            ),
            RaisedButton(
              child: Text('/text'),
              onPressed: () {
                Navigator.of(context).pushNamed('/text');
              },
            ),
            Container(
              height: 50,
            ),
            RaisedButton(
              child: Text('Pop'),
              onPressed: () {
                if (!ModalRoute.of(context).isFirst) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
