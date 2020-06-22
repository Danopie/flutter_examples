import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class BottomTabBarAnimated extends StatefulWidget {
  @override
  _BottomTabBarAnimatedState createState() => _BottomTabBarAnimatedState();
}

class _BottomTabBarAnimatedState extends State<BottomTabBarAnimated>
    with TickerProviderStateMixin<BottomTabBarAnimated> {
  static const animDuration = Duration(milliseconds: 200);

  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("BottomTabBar"),
      ),
      bottomNavigationBar: buildBottomTabBar(),
    );
  }

  Widget buildBottomTabBar() {
    Widget buildBackground() {
      return ClipPath(
        clipper: HalfCurveClipper(middleOffset: 3 - _selectedIndex),
        child: Container(
          color: Colors.white,
          height: 70,
        ),
      );
    }

    Widget buildCircle() {
      return AnimatedAlign(
        duration: animDuration,
        curve: Curves.easeOut,
        alignment: Alignment((_selectedIndex - 1).toDouble(), -1),
        child: FractionallySizedBox(
          widthFactor: 1 / 3,
          child: CustomPaint(
            painter: CurveEdgePainter(),
            child: Container(
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              height: 70,
              width: 70,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.deepPurpleAccent),
                height: 55,
                width: 55,
              ),
            ),
          ),
        ),
      );
    }

    Widget buildItemRow() {
      return Container(
        height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TabBarItem(
                icon: Icons.home,
                title: "HOME",
                onPressed: () {
                  onUserSelectTab(0);
                },
                selected: _selectedIndex == 0,
              ),
            ),
            Expanded(
              child: TabBarItem(
                icon: Icons.search,
                title: "SEARCH",
                onPressed: () {
                  onUserSelectTab(1);
                },
                selected: _selectedIndex == 1,
              ),
            ),
            Expanded(
              child: TabBarItem(
                icon: Icons.person,
                title: "USER",
                onPressed: () {
                  onUserSelectTab(2);
                },
                selected: _selectedIndex == 2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 90,
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.bottomCenter,
        children: <Widget>[buildBackground(), buildCircle(), buildItemRow()],
      ),
    );
  }

  void onUserSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class CurveEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
//    final Rect beforeRect = Rect.fromLTWH(0, (size.height / 2) - 10, 10, 10);
//    final Rect largeRect = Rect.fromLTWH(10, 0, size.width - 20, 70);
//    final Rect afterRect = Rect.fromLTWH(size.width - 10, (size.height / 2) - 10, 10, 10);
//
//    canvas.drawRect(beforeRect, Paint()..color = Colors.green);
//    canvas.drawRect(largeRect, Paint()..color = Colors.green);
//    canvas.drawRect(afterRect, Paint()..color = Colors.green);

    final Rect rect = Rect.fromLTWH(0, 0, 15, size.height);
    canvas.drawRect(rect, Paint()..color = Colors.green);

    final path = Path();
    path.moveTo(0, size.height);
    path.arcTo(rect, vector.radians(90), vector.radians(-90), false);
    path.lineTo(20, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class HalfCurveClipper extends CustomClipper<Path> {
  int middleOffset;

  HalfCurveClipper({this.middleOffset});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 3);

    final controlPoint = Offset(size.width / middleOffset, 0);
    final endPoint = Offset(size.width, size.height / 3);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TabBarItem extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final String title;
  final Function onPressed;

  const TabBarItem(
      {Key key, this.icon, this.selected, this.title, this.onPressed})
      : super(key: key);

  @override
  _TabBarItemState createState() => _TabBarItemState();
}

class _TabBarItemState extends State<TabBarItem>
    with TickerProviderStateMixin<TabBarItem> {
  static const animDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onPressed,
      child: AnimatedAlign(
        duration: animDuration,
        alignment: widget.selected ? Alignment.center : Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: buildItems(),
        ),
      ),
    );
  }

  buildItems() {
    final widgets = List<Widget>();

    widgets.add(
      Icon(
        widget.icon,
        color: widget.selected ? Colors.white : Colors.deepPurpleAccent,
      ),
    );

    widgets.add(AnimatedContainer(
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: widget.selected ? 20 : 11, bottom: 5),
      duration: animDuration,
      child: AnimatedOpacity(
        curve: Curves.easeOut,
        opacity: widget.selected ? 1.0 : 0.0,
        child: widget.selected
            ? Text(
                widget.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )
            : null,
        duration: animDuration,
      ),
    ));

    return widgets;
  }
}
