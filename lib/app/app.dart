import 'package:flutter/material.dart';

import '../resources/strings/app_strings.dart';
import '../resources/theme/app_theme.dart';
import '../ui/pages/home_page.dart';

class HushnetApp extends StatelessWidget {
  const HushnetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
