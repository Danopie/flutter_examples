import 'package:flutter/material.dart';

class DotLoadingIndicator extends StatefulWidget {
  final int length;
  final Color color;
  final double size;

  const DotLoadingIndicator(
      {Key key, this.length = 4, this.color = Colors.red, this.size = 18})
      : super(key: key);

  @override
  _DotLoadingIndicatorState createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<DotLoadingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  int _nextAnimatingIndex;
  Tween<double> _sizeTween;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _nextAnimatingIndex = 0;
    _sizeTween = Tween<double>(begin: 1.0, end: 1.4);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
        setState(() {
          _nextAnimatingIndex = _getNextAnimationIndex(_nextAnimatingIndex);
        });
      }
    });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(widget.length + (widget.length - 1),
          (index) => index % 2 == 0 ? _buildDot(index / 2) : _buildMargin()),
    );
  }

  Widget _buildMargin() {
    return Container(
      width: widget.size / 3,
    );
  }

  Widget _buildDot(double dotIndex) {
    return ScaleTransition(
      scale: _nextAnimatingIndex == dotIndex
          ? _sizeTween.animate(
              CurvedAnimation(parent: _controller, curve: Curves.decelerate))
          : AlwaysStoppedAnimation(1.0),
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }

  int _getNextAnimationIndex(int currentIndex) {
    if (currentIndex < widget.length - 1) {
      return currentIndex + 1;
    } else {
      return 0;
    }
  }
}
