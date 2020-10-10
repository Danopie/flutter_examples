import 'package:build_context/build_context.dart';
import 'package:flutter/material.dart';

class MiniPlayerDemo extends StatefulWidget {
  @override
  _MiniPlayerDemoState createState() => _MiniPlayerDemoState();
}

class _MiniPlayerDemoState extends State<MiniPlayerDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text("Item $index"),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key key}) : super(key: key);
  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

enum MiniPlayerState { collapsed, collapsing, expanding, expanded }

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  double minHeight;
  double maxHeight;
  double height;
  AxisDirection direction;
  AnimationController heightController;
  Animation<double> heightAnimation;

  @override
  void initState() {
    heightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    height = minHeight = 60;
    maxHeight = 400;
    direction = AxisDirection.up;
    super.initState();
  }

  MiniPlayerState get _playerState {
    if (height == maxHeight) return MiniPlayerState.expanded;
    if (height == minHeight) return MiniPlayerState.collapsed;
    if (direction == AxisDirection.up) return MiniPlayerState.expanding;
    if (direction == AxisDirection.down) return MiniPlayerState.collapsing;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final targetHeight =
            _playerState == MiniPlayerState.collapsed ? maxHeight : minHeight;
        _animateToPosition(targetHeight);
      },
      onVerticalDragEnd: (details) {
        _animateToPosition(
            direction == AxisDirection.up ? maxHeight : minHeight);
      },
      onVerticalDragUpdate: (details) {
        final newHeight = height - details.primaryDelta;
        setState(() {
          height = newHeight.clamp(minHeight, maxHeight);
          direction =
              details.primaryDelta > 0 ? AxisDirection.down : AxisDirection.up;
        });
      },
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.white,
        child: Builder(
          builder: (context) {
            final ratio = (height - minHeight) / (maxHeight - minHeight);
            return Stack(
              children: [
                CoverImage(ratio: ratio),
                ControlCenter(
                  ratio: ratio,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Future _animateToPosition(double targetHeight) async {
    heightAnimation = heightController.drive(
        Tween<double>(begin: height, end: targetHeight)
            .chain(CurveTween(curve: Curves.decelerate)));
    final listener = () {
      setState(() {
        height = heightAnimation.value;
      });
    };
    heightAnimation.addListener(listener);

    await heightController.forward(from: 0.0);
    heightAnimation.removeListener(listener);
  }
}

class CoverImage extends StatelessWidget {
  final double ratio;

  const CoverImage({Key key, this.ratio}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          AlignmentTween(begin: Alignment.centerLeft, end: Alignment(0, -0.8))
              .chain(CurveTween(curve: Curves.easeIn))
              .transform(ratio),
      child: Builder(
        builder: (context) {
          final maxPictureWidth = context.mediaQuerySize.width / 2;

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: Tween<double>(
                        begin: 0,
                        end: (context.mediaQuerySize.width / 2) -
                            (maxPictureWidth / 2))
                    .transform(ratio),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: maxPictureWidth, maxWidth: maxPictureWidth),
                child: Image.network(
                  "https://avatar-nct.nixcdn.com/singer/avatar/2020/05/20/5/f/e/3/1589944002038_600.jpg",
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Opacity(
                  opacity: Tween<double>(begin: 1.0, end: 0.0)
                      .chain(CurveTween(curve: Interval(0.0, 0.1)))
                      .transform(ratio),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gặp lại nhau khi hoa nở',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Nguyên Hà',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: Tween<double>(begin: 1.0, end: 0.0)
                    .chain(CurveTween(curve: Interval(0.0, 0.1)))
                    .transform(ratio),
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.pause,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ControlCenter extends StatelessWidget {
  final double ratio;

  const ControlCenter({Key key, this.ratio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0.7),
      child: Opacity(
        opacity: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Interval(0.4, 0.7)))
            .transform(ratio),
        child: Transform.translate(
          offset: Tween<Offset>(begin: Offset(0, 200), end: Offset(0, 0))
              .transform(ratio),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Sau này gặp lại nhau khi hoa nở'),
              Container(
                height: 16,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Icon(Icons.play_arrow),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                ],
              ),
              Container(
                height: 16,
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(
                    value: 0.5,
                  )),
              Container(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
