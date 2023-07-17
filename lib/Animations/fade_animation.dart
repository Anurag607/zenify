import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final double verticalTransition;
  final Widget child;

  const FadeAnimation(this.delay, this.verticalTransition, this.child,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween('opacity', Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300))
          .thenTween('y', Tween(begin: verticalTransition, end: 0.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);

    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.get("opacity"),
        child: Transform.translate(
          offset: Offset(0, value.get("y")),
          child: Container(
            child: child,
          ),
        ),
      ),
    );
  }
}
