import 'package:flutter/material.dart';

class RollingAmount extends StatelessWidget {
  final double value;
  final TextStyle style;
  final Duration duration;

  const RollingAmount({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo, // Starts fast, settles smoothly
      builder: (context, animatedValue, child) {
        return Text(
          "\$${animatedValue.toStringAsFixed(2)}",
          style: style,
        );
      },
    );
  }
}