import 'package:flutter/material.dart';

import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';

class ConnectToggleButton extends StatelessWidget {
  const ConnectToggleButton({
    super.key,
    required this.status,
    required this.onConnect,
    required this.onDisconnect,
  });

  final VpnConnectionStatus status;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isBusy =
        status == VpnConnectionStatus.connecting ||
        status == VpnConnectionStatus.disconnecting;
    final isConnected = status == VpnConnectionStatus.connected;

    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        onPressed: isBusy ? null : (isConnected ? onDisconnect : onConnect),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isConnected
              ? AppColors.primaryDark
              : AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: isBusy
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isConnected ? AppStrings.disconnect : AppStrings.connect,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
