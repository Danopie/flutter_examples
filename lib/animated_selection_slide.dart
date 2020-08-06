import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnimatedSelectionSlideDemo extends StatefulWidget {
  @override
  _AnimatedSelectionSlideDemoState createState() =>
      _AnimatedSelectionSlideDemoState();
}

class _AnimatedSelectionSlideDemoState
    extends State<AnimatedSelectionSlideDemo> {
  final List<int> items = List<int>.generate(10, (index) => index);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          return CardItem(
            key: ValueKey(index),
            index: items[index],
            onRemove: () {
              _removeItem(index);
            },
          );
        },
        itemCount: items.length,
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }
}

const double kMaxHorizontalOffset = 130;
const double kMaxVerticalOffset = 10;

enum CardItemState { Idle, Armed, Removing }

class CardItem extends StatefulHookWidget {
  final int index;
  final Function onRemove;

  const CardItem({Key key, this.index, this.onRemove}) : super(key: key);

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> with TickerProviderStateMixin {
  AnimationController shadowController;

  AnimationController bounceBackController;
  Animation<Offset> _bounceBackAnimation;

  AnimationController actionsAppearController;
  AnimationController removeItemController;

  double dx;
  double dy;

  CardItemState state;

  @override
  void initState() {
    state = CardItemState.Idle;

    dx = 0;
    dy = 0;

    _initShadow();
    _initAction();
    _listenForBounceBack();

    super.initState();
  }

  void _initShadow() {
    shadowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 60),
    );
  }

  void _listenForBounceBack() {
    bounceBackController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    bounceBackController.addListener(() {
      setState(() {
        dx = _bounceBackAnimation.value.dx;
        dy = _bounceBackAnimation.value.dy;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    useValueListenable(shadowController);
    useValueListenable(removeItemController);
    useValueListenable(actionsAppearController);
    useValueListenable(removeItemController);

    return FadeTransition(
      opacity: removeItemController.drive(Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Interval(0, 0.4)))),
      child: SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: removeItemController.drive(
            Tween<double>(begin: 1.0, end: 0.0)
                .chain(CurveTween(curve: Curves.decelerate))),
        child: GestureDetector(
          onPanStart: _handleDragStart,
          onPanUpdate: _handleDragUpdate,
          onPanEnd: _handleDragEnd,
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            color: Colors.grey[200],
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: ActionsCard(
                    animation: actionsAppearController,
                    dy: dy,
                    dx: dx,
                    onSelected: () async {
                      if (state != CardItemState.Removing) {
                        setState(() {
                          state = CardItemState.Removing;
                        });
                        await Future.delayed(Duration(milliseconds: 100));
                        await removeItemController.forward(from: 0.0);
                        widget.onRemove();
                      }
                    },
                  ),
                ),
                Transform.translate(
                  offset: Offset(dx, dy),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        Tween<double>(begin: 0, end: 4)
                            .evaluate(shadowController)),
                    elevation: Tween<double>(begin: 0, end: 8)
                        .evaluate(shadowController),
                    child: ItemInfo(index: widget.index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (state == CardItemState.Armed) {
      if ((details.delta.dy < 0 && dy > -kMaxVerticalOffset) ||
          (details.delta.dy > 0 && dy < kMaxVerticalOffset)) {
        setState(() {
          dy += details.delta.dy;
        });
      }
    }

    if ((details.delta.dx < 0) || (details.delta.dx > 0 && dx < 0)) {
      if (dx.abs() > kMaxHorizontalOffset) {
        setState(() {
          dx += details.delta.dx / (dx.abs() / 15);

          if (state == CardItemState.Idle) {
            state = CardItemState.Armed;
            actionsAppearController.forward();
          }
        });
      } else {
        actionsAppearController.reverse();
        setState(() {
          dx += details.delta.dx;
          if (state == CardItemState.Armed) {
            state = CardItemState.Idle;
            actionsAppearController.reverse();
          }
        });
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    shadowController.forward();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (state == CardItemState.Removing) {
      return;
    } else if (state == CardItemState.Idle) {
      shadowController.reverse();
      _bounceBack(0);
    } else {
      _bounceBack(-kMaxHorizontalOffset);
    }
  }

  void _bounceBack(double end) {
    _bounceBackAnimation = bounceBackController.drive(
        Tween<Offset>(begin: Offset(dx, dy), end: Offset(end, 0))
            .chain(CurveTween(curve: Curves.bounceInOut)));
    bounceBackController.reset();
    bounceBackController.forward();
  }

  void _initAction() {
    actionsAppearController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    removeItemController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }
}

class ActionsCard extends StatelessWidget {
  final Animation<double> animation;
  final double dy;
  final double dx;
  final Function onSelected;

  const ActionsCard(
      {Key key, this.animation, this.dy, this.dx, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 24),
      child: Row(
        children: [
          FadeTransition(
            opacity: animation,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87)),
            ),
          ),
          Container(
            width: 30,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAction(Icons.star, Colors.blue, Interval(0, 0.4),
                  () => dy > 5, 1, 1),
              Container(
                height: 4,
              ),
              _buildAction(Icons.delete, Colors.red, Interval(0.2, 0.6),
                  () => dy > -5 && dy < 5, 0, 2, onSelected),
              Container(
                height: 4,
              ),
              _buildAction(
                Icons.arrow_upward,
                Colors.black87,
                Interval(0.5, 1.0),
                () => dy < -5,
                -1,
                3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildAction(IconData icon, Color color, Curve curve,
      bool Function() qualifier, double diagonalRate, int index,
      [Function onSelected]) {
    return ActionIcon(
        icon: icon,
        color: color,
        curve: curve,
        selected: qualifier() && dx.abs() - kMaxHorizontalOffset > 0,
        diagonalRate: diagonalRate,
        animation: animation,
        dx: dx,
        index: index,
        onSelected: onSelected);
  }
}

const double kExtendedXOffset = 10;

class ActionIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Curve curve;
  final bool selected;
  final double diagonalRate;
  final Animation<double> animation;
  final double dx;
  final int index;
  final Function onSelected;

  const ActionIcon(
      {Key key,
      this.diagonalRate,
      this.icon,
      this.color,
      this.curve,
      this.selected,
      this.animation,
      this.dx,
      this.index,
      this.onSelected})
      : super(key: key);
  @override
  _ActionIconState createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 160));
    _controller.addListener(
      () {
        if (_controller.value == 1.0) {
          widget.onSelected();
        }
      },
    );
    super.initState();
  }

  @override
  void didUpdateWidget(ActionIcon oldWidget) {
    if (_controller.value > 0 && !widget.selected) {
      _controller.reverse();
    }

    if (widget.selected) {
      double offsetRatio = 0;
      double xOffset = widget.dx.abs();
      offsetRatio = (xOffset - kMaxHorizontalOffset) / kExtendedXOffset;
      offsetRatio = min(offsetRatio, 1.0);
      _controller.animateTo(offsetRatio);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
                  begin: Offset(0, 0),
                  end: Offset(-55, 29 * widget.diagonalRate))
              .evaluate(_controller),
          child: child,
        );
      },
      child: Transform.translate(
        offset: Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0))
            .chain(CurveTween(curve: Curves.decelerate))
            .chain(CurveTween(curve: widget.curve))
            .evaluate(widget.animation),
        child: Container(
          child: Icon(
            widget.icon,
            size: 16,
            color: Colors.white,
          ),
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class ItemInfo extends StatelessWidget {
  final int index;

  const ItemInfo({Key key, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 12,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT7nMcLjweymPromT7_MChCJn1kS0ZR5i4U5A&usqp=CAU"),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Adam Wyman $index",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                  Container(
                    height: 6,
                  ),
                  Text(
                    "I spent a minute starring this image, which is the ultimate goal",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 14),
              child: Text(
                "8:30am",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              )),
        ],
      ),
    );
  }
}
