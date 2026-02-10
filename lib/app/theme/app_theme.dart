import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide theme configuration.
abstract final class AppTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.baloo2TextTheme();
    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorSchemeSeed: const Color(0xFF0050D0),
      brightness: Brightness.light,
    );
  }

  static final questionStyle = GoogleFonts.baloo2(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 2,
  );

  static final answerStyle = GoogleFonts.baloo2(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    shadows: const [
      Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static final pillStyle = GoogleFonts.baloo2(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final levelStyle = GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF0060E0),
  );
}
