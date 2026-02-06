import 'package:flutter/material.dart';

/// Pastel color palette matching the screenshot design.
abstract final class AppColors {
  // Background gradient.
  static const bgTop = Color(0xFFB8D4F0);
  static const bgMiddle = Color(0xFFD4CEED);
  static const bgBottom = Color(0xFFF0D0E0);

  // Question card.
  static const cardGradientStart = Color(0xFF7B6BDB);
  static const cardGradientEnd = Color(0xFF5B7FE8);
  static const neonCyan = Color(0xFF00E5FF);

  // HUD pills.
  static const pillPurple = Color(0xFF7B6BDB);
  static const pillText = Colors.white;

  // Answer button colors.
  static const coral = Color(0xFFF07A6E);
  static const green = Color(0xFF6BC88A);
  static const cyan = Color(0xFF6EC6E8);
  static const purple = Color(0xFFC07ADB);

  // Bot avatar.
  static const botBlue = Color(0xFF5B7FE8);

  // Floating shapes.
  static const shapeTeal = Color(0xFF4ECDC4);
  static const shapePink = Color(0xFFF0A0C0);
  static const shapeBlue = Color(0xFF80B0E8);

  // Misc.
  static const starGold = Color(0xFFFFCA28);
  static const timerRed = Color(0xFFFF5252);
  static const white = Colors.white;
}
