import 'package:flutter/material.dart';

import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../atoms/status_dot.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({super.key, required this.status});

  final VpnConnectionStatus status;

  String get _label {
    switch (status) {
      case VpnConnectionStatus.connected:
        return AppStrings.statusConnected;
      case VpnConnectionStatus.connecting:
        return AppStrings.statusConnecting;
      case VpnConnectionStatus.disconnecting:
        return AppStrings.statusDisconnecting;
      case VpnConnectionStatus.error:
        return AppStrings.statusError;
      case VpnConnectionStatus.disconnected:
        return AppStrings.statusDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatusDot(status: status),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
