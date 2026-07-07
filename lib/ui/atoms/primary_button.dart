import 'package:flutter/material.dart';

import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';

/// Atom — 채워진 주요 액션 버튼 (design.pen `Button/Primary`).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// 부모 너비를 채운다 (권한 게이트의 전체 폭 버튼).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space4,
            horizontal: AppSpacing.space6,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.bodyStrong.copyWith(color: AppColors.primaryOn),
          ),
        ),
      ),
    );
  }
}
