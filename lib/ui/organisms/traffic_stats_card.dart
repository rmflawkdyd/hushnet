import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/traffic_formatters.dart';
import '../../data/models/vpn_traffic.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../molecules/stat_row.dart';

/// Organism — 트래픽 통계 카드 (design.pen `StatsCard`). 연결됨 상태에서만 표시.
class TrafficStatsCard extends StatelessWidget {
  const TrafficStatsCard({super.key, required this.traffic});

  final VpnTraffic traffic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: StatRow(
              icon: LucideIcons.arrowDown,
              value: formatSpeed(traffic.downloadBytesPerSecond),
              label: AppStrings.statDownload,
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: StatRow(
              icon: LucideIcons.arrowUp,
              value: formatSpeed(traffic.uploadBytesPerSecond),
              label: AppStrings.statUpload,
            ),
          ),
        ],
      ),
    );
  }
}
