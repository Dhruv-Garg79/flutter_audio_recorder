import 'package:flutter/material.dart';

class BlinkWidget extends StatefulWidget {
  final Widget child;
  final int duration;

  const BlinkWidget({Key? key, required this.child, required this.duration})
      : super(key: key);

  @override
  _BlinkWidgetState createState() => _BlinkWidgetState();
}

class _BlinkWidgetState extends State<BlinkWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.duration),
  );

  late final Animation<double> _animation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ),
  );

  @override
  void initState() {
    super.initState();
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
