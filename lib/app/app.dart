import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../ui/screens/main_menu_screen.dart';

/// Root application widget.
class ArithmeticApp extends StatelessWidget {
  const ArithmeticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aritme(bu)tikk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainMenuScreen(),
    );
  }
}
