import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/vpn_server.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/flag_icon.dart';

/// Molecule — 현재 서버 표시 + 변경 진입점 (design.pen `ServerBar`).
/// Home 4개 상태에 공통으로 노출되며, 탭하면 서버 선택 바텀시트를 연다.
class ServerBar extends StatelessWidget {
  const ServerBar({super.key, required this.server, required this.onTap});

  final VpnServer? server;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space3,
            horizontal: AppSpacing.space4,
          ),
          child: Row(
            children: [
              Expanded(child: _buildCurrentServer()),
              Text(
                AppStrings.serverChange,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentServer() {
    final server = this.server;
    if (server == null) {
      return Text(
        AppStrings.serverNotSelected,
        style: AppTypography.caption,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      children: [
        FlagIcon(countryCode: server.countryCode, width: 18),
        const SizedBox(width: AppSpacing.space2),
        Flexible(
          child: Text(
            server.country,
            style: AppTypography.bodyStrong,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
