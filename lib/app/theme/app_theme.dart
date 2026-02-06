import 'package:flutter/material.dart';

/// App-wide theme configuration.
abstract final class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'sans-serif',
    colorSchemeSeed: const Color(0xFF7B6BDB),
    brightness: Brightness.light,
  );

  static const questionStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 2,
  );

  static const answerStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    shadows: [
      Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static const pillStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const levelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color(0xFF5B7FE8),
  );
}
