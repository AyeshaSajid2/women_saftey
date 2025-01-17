import 'dart:async';

import 'package:flutter/material.dart';

class Animator extends StatefulWidget {
  final Widget child;
  final Duration time;

  Animator(this.child, this.time);

  @override
  _AnimatorState createState() => _AnimatorState();
}

class _AnimatorState extends State<Animator> with SingleTickerProviderStateMixin {
  late Timer timer;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 290), vsync: this);
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    timer = Timer(widget.time, () {
      if (mounted) animationController.forward();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - animation.value!) * 20),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class WidgetAnimator extends StatelessWidget {
  final Widget child;

  WidgetAnimator(this.child);

  @override
  Widget build(BuildContext context) {
    return Animator(child, wait());
  }

  Duration wait() {
    Duration duration = Duration();
    return duration;
  }
}
