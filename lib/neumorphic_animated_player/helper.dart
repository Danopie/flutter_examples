
import 'package:flutter/material.dart';

class IdleTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final bool isOpaque;

  CustomPageRoute({
    this.child,
    this.isOpaque = false,
  }) : super(pageBuilder: (context, animation, secondaryAnimation) {
    return child;
  });

  @override
  bool get opaque => isOpaque;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
