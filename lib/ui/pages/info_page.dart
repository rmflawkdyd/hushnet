import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../organisms/hushnet_top_bar.dart';

/// 정보 화면 (design.pen `정보 화면`).
/// No-log 설명 + 개인정보처리방침(스토어 심사 필수 인앱 접근점) + 버전.
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppStrings.privacyPolicyUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HushnetTopBar(
                leadingIcon: LucideIcons.arrowLeft,
                leadingIconColor: AppColors.textPrimary,
                title: AppStrings.infoTitle,
                onLeadingTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.space6),
              const _NoLogCard(),
              const SizedBox(height: AppSpacing.space6),
              _PolicyRow(onTap: _openPrivacyPolicy),
              const SizedBox(height: AppSpacing.space6),
              Text(
                AppStrings.versionFooter(AppStrings.appVersion),
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoLogCard extends StatelessWidget {
  const _NoLogCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                size: 20,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(AppStrings.noLogCardTitle, style: AppTypography.bodyStrong),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(AppStrings.noLogCardBody, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.fileText,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.space3),
                Text(AppStrings.privacyPolicy, style: AppTypography.body),
              ],
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
