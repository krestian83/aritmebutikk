import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Bottom bar showing robot mascot avatar and level pill.
class LevelIndicator extends StatelessWidget {
  final ValueNotifier<int> level;

  const LevelIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: level,
      builder: (context, currentLevel, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Robot mascot avatar.
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.botBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.botBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('\uD83E\uDD16', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // Level pill.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Niv\u00E5 $currentLevel',
                style: AppTheme.levelStyle,
              ),
            ),
            const SizedBox(width: 12),
            // Decorative star.
            const Text('\u2728', style: TextStyle(fontSize: 20)),
          ],
        );
      },
    );
  }
}
