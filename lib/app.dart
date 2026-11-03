import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/app_scope.dart';
import 'theme/app_theme.dart';

class ColoringApp extends StatefulWidget {
  const ColoringApp({super.key, required this.services});

  final AppServices services;

  @override
  State<ColoringApp> createState() => _ColoringAppState();
}

class _ColoringAppState extends State<ColoringApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Write any debounced saves before the OS may suspend or kill the app.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      widget.services.artworks.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: MaterialApp(
        title: 'Color Sprout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashScreen(),
      ),
    );
  }
}
