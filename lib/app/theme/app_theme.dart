import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App-wide theme configuration.
abstract final class AppTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.nunitoTextTheme();
    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorSchemeSeed: AppColors.menuTeal,
      brightness: Brightness.light,
    );
  }

  static final questionStyle = GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 2,
  );

  static final answerStyle = GoogleFonts.nunito(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    shadows: const [
      Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static final pillStyle = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final levelStyle = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.menuTeal,
  );
}
