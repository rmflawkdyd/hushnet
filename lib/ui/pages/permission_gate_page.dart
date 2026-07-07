import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preference_keys.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/primary_button.dart';
import '../state/vpn_controller.dart';
import 'home_page.dart';

/// 권한 요청 하드 게이트 (design.pen `권한 요청`). 최초 1회.
/// [권한 허용하기] → OS 권한 다이얼로그. 허용 전에는 앱을 사용할 수 없다.
/// Google Play 현저한 고지 요건(목적·접근 범위·처리)을 아이콘 포인트 3개로 담당.
class PermissionGatePage extends ConsumerStatefulWidget {
  const PermissionGatePage({super.key});

  @override
  ConsumerState<PermissionGatePage> createState() =>
      _PermissionGatePageState();
}

class _PermissionGatePageState extends ConsumerState<PermissionGatePage> {
  bool _requesting = false;

  Future<void> _requestPermission() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    bool granted;
    try {
      granted = await ref.read(vpnServiceProvider).requestPermission();
    } catch (_) {
      granted = false;
    }
    if (!mounted) return;
    if (!granted) {
      setState(() => _requesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.permissionDenied)),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.permissionGateDone, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            0,
            AppSpacing.space6,
            AppSpacing.space8,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        size: 44,
                        color: AppColors.primaryOn,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    Text(
                      AppStrings.permissionTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.heading,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    const _DisclosurePoints(),
                  ],
                ),
              ),
              PrimaryButton(
                label: AppStrings.permissionAllow,
                expand: true,
                onPressed: _requesting ? null : _requestPermission,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclosurePoints extends StatelessWidget {
  const _DisclosurePoints();

  @override
  Widget build(BuildContext context) {
    const points = <(IconData, String)>[
      (LucideIcons.shieldCheck, AppStrings.permissionPointUsage),
      (LucideIcons.lock, AppStrings.permissionPointScope),
      (LucideIcons.eyeOff, AppStrings.permissionPointNoLog),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (icon, text) in points)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  text,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
