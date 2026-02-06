import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// A glossy 3D bubble answer button with layered gradients.
class AnswerButton extends StatefulWidget {
  final int value;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const AnswerButton({
    super.key,
    required this.value,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.enabled) _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _scaleController.reverse();
    if (widget.enabled) widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: CustomPaint(
          painter: _BubblePainter(color: widget.color),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Center(
              child: Text('${widget.value}', style: AppTheme.answerStyle),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a glossy 3D bubble effect.
class _BubblePainter extends CustomPainter {
  final Color color;

  _BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Shadow.
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center + const Offset(0, 4), radius, shadowPaint);

    // Base sphere gradient.
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          Color.lerp(color, Colors.white, 0.3)!,
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // Rim highlight (top-left).
    final rimPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    // Specular highlight (small white dot).
    final specCenter = Offset(
      center.dx - radius * 0.25,
      center.dy - radius * 0.25,
    );
    final specPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: specCenter, radius: radius * 0.35),
          );
    canvas.drawCircle(specCenter, radius * 0.35, specPaint);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}
