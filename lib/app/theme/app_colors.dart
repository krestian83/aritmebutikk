import 'package:flutter/material.dart';

/// Color palette – bold Big Sur–inspired waves.
abstract final class AppColors {
  // Background gradient (cyan → light wash → warm orange).
  static const bgTop = Color(0xFF00D0FF);
  static const bgMiddle = Color(0xFFC0D8F8);
  static const bgBottom = Color(0xFFFF8020);

  // Question card.
  static const cardGradientStart = Color(0xFF0050D0);
  static const cardGradientEnd = Color(0xFF0070E8);
  static const neonCyan = Color(0xFFFFAA00);

  // HUD pills.
  static const pillBlue = Color(0xFF0050D0);
  static const pillText = Colors.white;

  // Answer button colors.
  static const coral = Color(0xFFFF2A10);
  static const green = Color(0xFF30A860);
  static const cyan = Color(0xFF00B8E0);
  static const orange = Color(0xFFFF9800);

  // Bot avatar.
  static const botBlue = Color(0xFF0060E0);

  // Floating shapes.
  static const shapeCyan = Color(0xFF00D0FF);
  static const shapeOrange = Color(0xFFFF8020);
  static const shapeBlue = Color(0xFF2060D8);

  // Outlines – black for thin border contrast.
  static const outline = Color(0xFF000000);

  // Misc.
  static const starGold = Color(0xFFFFAA00);
  static const timerRed = Color(0xFFFF2A10);
  static const white = Colors.white;
}
