import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/l10n/strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../game/models/game_category.dart';
import 'confetti_particle.dart';

/// Full-screen celebration overlay shown when a player maxes
/// out all available credits in a category.
class CategoryMaxCelebration extends StatefulWidget {
  final GameCategory category;
  final VoidCallback onComplete;

  const CategoryMaxCelebration({
    super.key,
    required this.category,
    required this.onComplete,
  });

  @override
  State<CategoryMaxCelebration> createState() => _CategoryMaxCelebrationState();
}

class _CategoryMaxCelebrationState extends State<CategoryMaxCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;
  late final String _message;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    final messages = S.current.celebrationMessages;
    _message = messages[_random.nextInt(messages.length)];

    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 7000),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onComplete();
            }
          })
          ..forward();

    _particles = List.generate(60, (_) {
      return ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.05 - _random.nextDouble() * 0.1,
        vx: (_random.nextDouble() - 0.5) * 0.3,
        vy: 0.3 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        size: 5 + _random.nextDouble() * 9,
        color: confettiColors[_random.nextInt(confettiColors.length)],
        wobblePhase: _random.nextDouble() * 2 * pi,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onComplete,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                    gravity: 0.3,
                    fadeStart: 0.7,
                    wobble: true,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.2, curve: Curves.elasticOut),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u2B50', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.category.icon} '
                      '${widget.category.label} '
                      '${widget.category.icon}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.starGold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      S.current.tapToContinue,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
