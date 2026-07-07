import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/preference_keys.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/permission_gate_page.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final permissionGateDone =
      prefs.getBool(PreferenceKeys.permissionGateDone) ?? false;

  runApp(
    ProviderScope(
      child: HushnetApp(
        home: permissionGateDone
            ? const HomePage()
            : const PermissionGatePage(),
      ),
    ),
  );
}
