import 'package:flutter/material.dart';

class AnchoredRouteDemo extends StatefulWidget {
  @override
  _AnchoredRouteDemoState createState() => _AnchoredRouteDemoState();
}

class _AnchoredRouteDemoState extends State<AnchoredRouteDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AnchoredRouteDemo"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListItem(index: index),
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final int index;

  const ListItem({Key key, this.index}) : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _heroKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Item ${widget.index}",
      ),
      onTap: () {
        _handleOnTap(context, widget.index);
      },
      leading: Hero(
        key: _heroKey,
        tag: "Hero${widget.index}",
        child: ProfilePicture(
          size: 40,
        ),
        createRectTween: (begin, end) {
          final rectTween = RectTween(begin: begin, end: end);
          return rectTween;
        },
      ),
    );
  }

  void _handleOnTap(BuildContext context, int index) {
    Navigator.of(context).push(AnchorCircleRoute(
      anchorContext: _heroKey.currentContext,
      builder: (context) => DetailPage(
        index: index,
      ),
    ));
  }
}

class AnchorCircleRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final BuildContext anchorContext;

  AnchorCircleRoute({
    this.builder,
    this.anchorContext,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            RenderBox renderBox = anchorContext.findRenderObject();
            final size = renderBox.size;
            final offset = renderBox.localToGlobal(Offset.zero);

            return CustomPaint(
              painter: AnchorRouteShadowPainter(animation, offset, size),
              child: ClipPath(
                  clipper: AnchorRouteClipper(animation, offset, size),
                  child: builder(context)),
            );
          },
          opaque: false,
          transitionDuration: Duration(milliseconds: 500),
        );
}

class AnchorRouteShadowPainter extends CustomPainter
    with AnchorRouteDecoratorMixin {
  final Animation<double> radiusAnimation;
  final Offset offset;
  final Size itemSize;

  AnchorRouteShadowPainter(this.radiusAnimation, this.offset, this.itemSize)
      : super(repaint: radiusAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = getRect(offset, itemSize, size, radiusAnimation);
    canvas.drawShadow(
        Path()..addOval(rect.inflate(14)), Colors.black38, 8, true);
    final path = Path()..addOval(rect.inflate(4));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(AnchorRouteShadowPainter oldDelegate) {
    return oldDelegate.radiusAnimation != this.radiusAnimation;
  }
}

class AnchorRouteClipper extends CustomClipper<Path>
    with AnchorRouteDecoratorMixin {
  final Animation<double> radiusAnimation;
  final Offset offset;
  final Size itemSize;

  AnchorRouteClipper(this.radiusAnimation, this.offset, this.itemSize)
      : super(reclip: radiusAnimation);

  @override
  Path getClip(Size size) {
    final rect = getRect(offset, itemSize, size, radiusAnimation);
    final path = Path()..addOval(rect);
    return path;
  }

  @override
  bool shouldReclip(AnchorRouteClipper oldClipper) {
    return oldClipper.radiusAnimation != this.radiusAnimation;
  }
}

mixin AnchorRouteDecoratorMixin {
  Offset getCenter(Offset offset, Size itemSize) =>
      Offset((offset.dx + itemSize.width) / 2, offset.dy + itemSize.height / 2);

  Rect getRect(Offset offset, Size itemSize, Size targetSize,
          Animation<double> animation) =>
      Rect.fromCircle(
          center: getCenter(offset, itemSize),
          radius: Tween<double>(begin: itemSize.width, end: targetSize.height)
              .evaluate(animation));
}

class DetailPage extends StatefulWidget {
  final int index;

  const DetailPage({Key key, this.index}) : super(key: key);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag: "Hero${widget.index}",
            child: ProfilePicture(
              size: 120,
            ),
            createRectTween: (begin, end) {
              final rectTween = RectTween(begin: begin, end: end);
              return rectTween;
            },
          ),
          Container(
            height: 24,
          ),
          Text("John Doe"),
        ],
      ),
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final double size;

  const ProfilePicture({Key key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: CircleAvatar(
        maxRadius: size,
        backgroundImage: NetworkImage(
            "https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg"),
      ),
    );
  }
}
