import 'package:flutter/material.dart';

import '../game/services/music_service.dart';
import '../ui/screens/main_menu_screen.dart';
import 'theme/app_theme.dart';

/// Root application widget.
class ArithmeticApp extends StatefulWidget {
  const ArithmeticApp({super.key});

  @override
  State<ArithmeticApp> createState() => _ArithmeticAppState();
}

class _ArithmeticAppState extends State<ArithmeticApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        MusicService.instance.stop();
      case AppLifecycleState.resumed:
        MusicService.instance.start();
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => MusicService.instance.start(),
      child: MaterialApp(
        title: 'Aritme(bu)tikk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainMenuScreen(),
      ),
    );
  }
}
