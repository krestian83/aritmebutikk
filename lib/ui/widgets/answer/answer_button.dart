import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// A solid colored circular answer button with a fixed tap animation.
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    // Play full forward-then-reverse animation regardless of
    // how long the user holds the button.
    _controller.forward(from: 0.0).then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final lighter = Color.lerp(widget.color, Colors.white, 0.25)!;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 0→1→0 curve: peaks at midpoint.
          final t = Curves.easeOutCubic.transform(_controller.value);
          final scale = 1.0 - t * 0.06;
          final blur = 8.0 - t * 3.0;
          final offset = 4.0 - t * 2.0;
          final bright = Color.lerp(
            widget.color,
            Colors.white,
            t * 0.12,
          )!;
          final lightBright = Color.lerp(lighter, Colors.white, t * 0.12)!;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [lightBright, bright],
                ),
                border: Border.all(color: AppColors.outline),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: blur,
                    offset: Offset(0, offset),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: Text('${widget.value}', style: AppTheme.answerStyle),
        ),
      ),
    );
  }
}
