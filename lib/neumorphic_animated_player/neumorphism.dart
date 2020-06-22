import 'package:flutter/material.dart';

class NeumorphismDemo extends StatefulWidget {
  @override
  _NeumorphismDemoState createState() => _NeumorphismDemoState();
}

class _NeumorphismDemoState extends State<NeumorphismDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: NeuContainer(
          child: Text("Hello"),
          style: NeuStyle.Concave,
        ),
      ),
    );
  }
}

enum NeuStyle { Concave, Flat, Convex, Emboss }

class NeuContainer extends StatefulWidget {
  final Widget child;
  final Offset blurOffset;
  final Color color;
  final NeuStyle style;
  final EdgeInsets padding;
  final double width;
  final double height;
  final BorderRadius radius;
  final double distance;
  final double intensity;
  final bool hasShadow;
  final Function onTap;

  NeuContainer({
    Key key,
    this.child,
    this.distance = 10.0,
    this.color,
    this.style = NeuStyle.Concave,
    this.padding = const EdgeInsets.all(4.0),
    this.width,
    this.height,
    this.radius,
    this.intensity = 0.5,
    this.hasShadow = true,
    this.onTap,
  })  : this.blurOffset = Offset(distance / 2, distance / 2),
        super(key: key) {
    assert(intensity > 0 && intensity < 1.0);
  }

  @override
  _NeuContainerState createState() => _NeuContainerState();
}

class _NeuContainerState extends State<NeuContainer> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = this.widget.color ?? Theme.of(context).backgroundColor;
    final boxDecoration = _getBoxDecoration(color);

    return Listener(
      onPointerDown: widget.onTap != null ? _onPointerDown: null,
      onPointerUp: widget.onTap != null ? _onPointerUp: null,
      child: widget.onTap != null
          ? AnimatedContainer(
              alignment: Alignment.center,
              width: widget.width,
              height: widget.height,
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: boxDecoration,
              child: widget.child,
            )
          : Container(
              alignment: Alignment.center,
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: boxDecoration,
              child: widget.child,
            ),
    );
  }

  BoxDecoration _getBoxDecoration(Color color) {
    switch (widget.style) {
      case NeuStyle.Concave:
        return BoxDecoration(
          borderRadius: widget.radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isPressed ? color : color.mix(Colors.black, .2),
              _isPressed ? color.mix(Colors.black, .05) : color,
              _isPressed ? color.mix(Colors.black, .05) : color,
              color.mix(Colors.white, _isPressed ? .2 : .5),
            ],
            stops: [
              0.0,
              .4,
              .6,
              1.0,
            ],
          ),
          boxShadow: _isPressed || !widget.hasShadow
              ? null
              : [
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: -widget.blurOffset,
                    color: color.mix(Colors.white, .6),
                  ),
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: widget.blurOffset,
                    color: color.mix(Colors.black, .2),
                  )
                ],
        );

      case NeuStyle.Emboss:
        return BoxDecoration(
          borderRadius: widget.radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isPressed ? color : color.mix(Colors.black, .2),
              _isPressed
                  ? color.mix(Colors.black, .05)
                  : color.mix(Colors.black, .1),
              _isPressed ? color.mix(Colors.black, .05) : color,
              color.mix(Colors.white, _isPressed ? .2 : .5),
            ],
            stops: [
              0.0,
              .2,
              .7,
              1.0,
            ],
          ),
        );

      case NeuStyle.Convex:
        return BoxDecoration(
          borderRadius: widget.radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isPressed ? color : color.mix(Colors.white, .2),
              _isPressed ? color.mix(Colors.white, .05) : color,
              _isPressed ? color.mix(Colors.white, .05) : color,
              color.mix(Colors.black, _isPressed ? .2 : .25),
            ],
            stops: [
              0.0,
              .4,
              .6,
              1.0,
            ],
          ),
          boxShadow: _isPressed || !widget.hasShadow
              ? null
              : [
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: -widget.blurOffset,
                    color: color.mix(Colors.white, .6),
                  ),
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: widget.blurOffset,
                    color: color.mix(Colors.black, .2),
                  )
                ],
        );

      case NeuStyle.Flat:
        return BoxDecoration(
          borderRadius: widget.radius,
          color: color,
          boxShadow: _isPressed || !widget.hasShadow
              ? null
              : [
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: -widget.blurOffset,
                    color: color.mix(Colors.white, .6),
                  ),
                  BoxShadow(
                    blurRadius: widget.distance,
                    offset: widget.blurOffset,
                    color: color.mix(Colors.black, .2),
                  )
                ],
        );

      default:
        return null;
    }
  }
}

extension ColorUtils on Color {
  Color mix(Color another, double amount) {
    return Color.lerp(this, another, amount);
  }
}
