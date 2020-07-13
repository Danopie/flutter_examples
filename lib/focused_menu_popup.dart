import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class FocusedMenuPopupDemo extends StatefulWidget {
  @override
  _FocusedMenuPopupDemoState createState() => _FocusedMenuPopupDemoState();
}

class _FocusedMenuPopupDemoState extends State<FocusedMenuPopupDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FocusedMenuPopup(
              child: Image.network(
                "https://i.pinimg.com/originals/3a/f0/e5/3af0e55ea66ea69e35145fb108b4a636.jpg",
                height: 160,
              ),
            ),
            FocusedMenuPopup(
              child: Image.network(
                "https://i.pinimg.com/originals/3a/f0/e5/3af0e55ea66ea69e35145fb108b4a636.jpg",
                height: 160,
              ),
            ),
            FocusedMenuPopup(
              child: Image.network(
                "https://i.pinimg.com/originals/3a/f0/e5/3af0e55ea66ea69e35145fb108b4a636.jpg",
                height: 160,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FocusedMenuPopup extends StatefulWidget {
  final Widget child;

  const FocusedMenuPopup({
    Key key,
    this.child,
  }) : super(key: key);
  @override
  _FocusedMenuPopupState createState() => _FocusedMenuPopupState();
}

class _FocusedMenuPopupState extends State<FocusedMenuPopup>
    with SingleTickerProviderStateMixin {
  OverlayEntry _overlayEntry;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _removeOverlay();
      },
      onLongPress: () {
        if (_overlayEntry == null) {
          _overlayEntry = _createOverlayPopup();
          Overlay.of(context).insert(_overlayEntry);
          _animationController.forward(from: 0.0);
        }
      },
      child: widget.child,
    );
  }

  Future<void> _removeOverlay() async {
    if (_overlayEntry != null) {
      await _animationController.reverse();
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  static const ITEM_SCALE = 1.2;
  static const MAX_MENU_HEIGHT = 150;

  OverlayEntry _createOverlayPopup() {
    RenderBox renderBox = context.findRenderObject();
    final itemSize = renderBox.size;
    final itemOffset = renderBox.localToGlobal(Offset.zero);
    final padding = 12.0;
    final scaledSize = itemSize * ITEM_SCALE;
    final scaledHeightOffset = (scaledSize.height - itemSize.height) / 2;
    final scaledWidthOffset = (scaledSize.width - itemSize.width) / 2;

    final isMenuBottom =
        itemOffset.dy <= MediaQuery.of(context).size.height / 2;

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _removeOverlay();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 5),
                child: Container(
                  color: Colors.black26,
                ),
              ),
              Positioned(
                left: itemOffset.dx - scaledWidthOffset,
                top: isMenuBottom ? (itemOffset.dy - scaledHeightOffset) : null,
                bottom: isMenuBottom
                    ? null
                    : MediaQuery.of(context).size.height -
                        itemOffset.dy -
                        itemSize.height -
                        scaledHeightOffset,
                child: Builder(
                  builder: (context) {
                    final children = <Widget>[
                      _buildItem(itemSize),
                      Container(
                        height: padding,
                      ),
                      _buildMenu(isMenuBottom),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          isMenuBottom ? children : children.reversed.toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(Size itemOriginalSize) {
    return SizedOverflowBox(
      size: Size(itemOriginalSize.width * ITEM_SCALE,
          itemOriginalSize.height * ITEM_SCALE),
      alignment: Alignment.center,
      child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: ITEM_SCALE).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.decelerate,
            ),
          ),
          alignment: Alignment.center,
          child: widget.child),
    );
  }

  Widget _buildMenu(bool isMenuBottom) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      )),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.4, end: 1).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.decelerate,
        )),
        alignment: isMenuBottom ? Alignment.topLeft : Alignment.bottomRight,
        child: Material(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Like",
                  style: TextStyle(fontSize: 12),
                ),
                Divider(),
                Text(
                  "View Profile",
                  style: TextStyle(fontSize: 12),
                ),
                Divider(),
                Text(
                  "Send as Message",
                  style: TextStyle(fontSize: 12),
                ),
                Divider(),
                Text(
                  "Report",
                  style: TextStyle(fontSize: 12),
                ),
                Divider(),
                Text(
                  "Not interested",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            width: 200,
          ),
        ),
      ),
    );
  }
}
