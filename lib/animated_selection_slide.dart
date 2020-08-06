import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnimatedSelectionSlideDemo extends StatefulWidget {
  @override
  _AnimatedSelectionSlideDemoState createState() =>
      _AnimatedSelectionSlideDemoState();
}

class _AnimatedSelectionSlideDemoState
    extends State<AnimatedSelectionSlideDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          return CardItem(index: index);
        },
        itemCount: 10,
      ),
    );
  }
}

enum CardItemState { Idle, Lifted, Armed }

class CardItem extends StatefulHookWidget {
  final int index;

  const CardItem({Key key, this.index}) : super(key: key);
  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> with TickerProviderStateMixin {
  static const double kMaxHorizontalOffset = 130;

  AnimationController shadowController;

  AnimationController bounceBackController;
  Animation<double> _bounceBackAnimation;

  AnimationController actionsAppearController;

  double dx;

  CardItemState state;

  @override
  void initState() {
    dx = 0;
    state = CardItemState.Idle;

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
        dx = _bounceBackAnimation.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    useValueListenable(shadowController);
    useValueListenable(actionsAppearController);

    return GestureDetector(
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
              ),
            ),
            Transform.translate(
              offset: Offset(dx, 0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    Tween<double>(begin: 0, end: 4).evaluate(shadowController)),
                elevation:
                    Tween<double>(begin: 0, end: 8).evaluate(shadowController),
                child: ItemInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
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
    if (state == CardItemState.Idle) {
      shadowController.reverse();
      _bounceBack(0);
    } else {
      _bounceBack(-kMaxHorizontalOffset);
    }
  }

  void _bounceBack(double end) {
    _bounceBackAnimation = bounceBackController.drive(
        Tween<double>(begin: dx, end: end)
            .chain(CurveTween(curve: Curves.bounceInOut)));
    bounceBackController.reset();
    bounceBackController.forward();
  }

  void _initAction() {
    actionsAppearController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }
}

class ActionsCard extends StatelessWidget {
  final Animation<double> animation;

  const ActionsCard({Key key, this.animation}) : super(key: key);

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
              _buildAction(Icons.star, Colors.blue, Interval(0, 0.4)),
              Container(
                height: 4,
              ),
              _buildAction(Icons.delete, Colors.red, Interval(0.2, 0.6)),
              Container(
                height: 4,
              ),
              _buildAction(
                  Icons.arrow_upward, Colors.black38, Interval(0.5, 1.0))
            ],
          ),
        ],
      ),
    );
  }

  _buildAction(IconData icon, Color color, Curve curve) {
    return Transform.translate(
      offset: Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0))
          .chain(CurveTween(curve: Curves.decelerate))
          .chain(CurveTween(curve: curve))
          .evaluate(animation),
      child: Container(
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ItemInfo extends StatelessWidget {
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
                    "Adam Wyman",
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
