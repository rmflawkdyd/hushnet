import 'package:flutter/material.dart';

import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/primary_button.dart';

/// Organism — 연결 중 서버 변경 차단 안내 팝업 (design.pen `서버 변경 불가 안내 (팝업)`).
///
/// 연결된 상태에서 서버를 바꿀 수 없음을 알린다. 단일 안내 + 닫기만 하며,
/// 연결 해제는 사용자가 직접 한다(연결 해제 선행 방침).
class ServerChangeBlockedDialog extends StatelessWidget {
  const ServerChangeBlockedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0xA60B0F17),
      builder: (_) => const ServerChangeBlockedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space6,
          AppSpacing.space8,
          AppSpacing.space6,
          AppSpacing.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.serverChangeBlockedTitle,
              textAlign: TextAlign.center,
              style: AppTypography.heading,
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              AppStrings.serverChangeBlockedBody,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.space6),
            PrimaryButton(
              label: AppStrings.confirm,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
