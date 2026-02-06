import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Displays the current question in a neon-glow bordered card.
class QuestionCard extends StatelessWidget {
  final String questionText;

  const QuestionCard({super.key, required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan, width: 2.5),
        boxShadow: [
          // Inner glow (neon effect).
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.6),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          // Card shadow.
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            questionText,
            style: AppTheme.questionStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
