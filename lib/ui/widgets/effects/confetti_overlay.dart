import 'dart:math';

import 'package:flutter/material.dart';

import 'confetti_particle.dart';

/// Full-screen confetti burst overlay for correct answers.
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiOverlay({super.key, this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onComplete?.call();
            }
          })
          ..forward();

    _particles = List.generate(20, (_) {
      return ConfettiParticle(
        x: 0.3 + _random.nextDouble() * 0.4,
        y: 0.4 + _random.nextDouble() * 0.2,
        vx: (_random.nextDouble() - 0.5) * 2.0,
        vy: -1.5 - _random.nextDouble() * 2.0,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        size: 4 + _random.nextDouble() * 8,
        color: confettiColors[_random.nextInt(confettiColors.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
