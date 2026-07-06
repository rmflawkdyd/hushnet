import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../molecules/connect_toggle_button.dart';
import '../molecules/connection_status_card.dart';
import '../state/vpn_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(vpnStatusProvider);
    final status =
        statusAsync.asData?.value ?? VpnConnectionStatus.disconnected;
    final message = ref.watch(vpnControllerProvider);
    final controller = ref.read(vpnControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppStrings.tagline,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              ConnectToggleButton(
                status: status,
                onConnect: controller.connect,
                onDisconnect: controller.disconnect,
              ),
              const SizedBox(height: AppSpacing.xl),
              ConnectionStatusCard(status: status),
              const SizedBox(height: AppSpacing.md),
              if (message != null)
                Text(
                  message,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
