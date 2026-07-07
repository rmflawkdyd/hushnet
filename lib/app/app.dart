import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../resources/strings/app_strings.dart';
import '../resources/theme/app_theme.dart';

class HushnetApp extends StatefulWidget {
  const HushnetApp({super.key, required this.home});

  final Widget home;

  @override
  State<HushnetApp> createState() => _HushnetAppState();
}

class _HushnetAppState extends State<HushnetApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: widget.home,
    );
  }
}
