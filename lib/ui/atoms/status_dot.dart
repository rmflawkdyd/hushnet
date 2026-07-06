import 'package:flutter/material.dart';

import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/theme/app_colors.dart';

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status, this.size = 14});

  final VpnConnectionStatus status;
  final double size;

  Color get _color {
    switch (status) {
      case VpnConnectionStatus.connected:
        return AppColors.statusConnected;
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.disconnecting:
        return AppColors.statusPending;
      case VpnConnectionStatus.error:
        return AppColors.statusError;
      case VpnConnectionStatus.disconnected:
        return AppColors.statusDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}
