import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/traffic_formatters.dart';
import '../../data/models/vpn_server.dart';
import '../../data/models/vpn_traffic.dart';
import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/secondary_button.dart';
import '../molecules/server_bar.dart';
import '../molecules/status_chip.dart';
import '../organisms/connect_button.dart';
import '../organisms/hushnet_top_bar.dart';
import '../organisms/server_change_blocked_dialog.dart';
import '../organisms/server_selection_sheet.dart';
import '../organisms/traffic_stats_card.dart';
import '../state/server_selection_controller.dart';
import '../state/vpn_controller.dart';
import 'info_page.dart';

enum HomeState { disconnected, connecting, connected, failed }

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  HomeState _resolveState(VpnConnectionStatus status, String? errorMessage) {
    switch (status) {
      case VpnConnectionStatus.error:
        return HomeState.failed;
      case VpnConnectionStatus.connected:
        return HomeState.connected;
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.disconnecting:
        return HomeState.connecting;
      case VpnConnectionStatus.disconnected:
        return errorMessage != null ? HomeState.failed : HomeState.disconnected;
    }
  }

  bool _canChangeServer(HomeState state) =>
      state == HomeState.disconnected || state == HomeState.failed;

  Future<void> _onServerSelected(WidgetRef ref, VpnServer server) async {
    await ref.read(selectedServerIdProvider.notifier).select(server.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(vpnStatusProvider);
    final status =
        statusAsync.asData?.value ?? VpnConnectionStatus.disconnected;
    final errorMessage = ref.watch(vpnControllerProvider);
    final controller = ref.read(vpnControllerProvider.notifier);
    final state = _resolveState(status, errorMessage);
    final currentServer = ref.watch(currentServerProvider);

    ref.listen<bool>(selectedServerVanishedProvider, (_, hasVanished) {
      if (!hasVanished) {
        return;
      }
      ref.read(selectedServerIdProvider.notifier).clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.serverVanished)),
      );
    });

    final traffic = state == HomeState.connected
        ? (ref.watch(vpnTrafficProvider).asData?.value ?? VpnTraffic.zero)
        : VpnTraffic.zero;
    final elapsed = state == HomeState.connected
        ? (ref.watch(connectionElapsedProvider).asData?.value ?? Duration.zero)
        : Duration.zero;

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
              HushnetTopBar(
                leadingSvgAsset: 'assets/icon/hushnet_logo.svg',
                leadingIconColor: AppColors.primary,
                title: AppStrings.appName,
                trailingIcon: LucideIcons.settings,
                onTrailingTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const InfoPage()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space3),
                child: ServerBar(
                  server: currentServer,
                  enabled: _canChangeServer(state),
                  onTap: () {
                    if (_canChangeServer(state)) {
                      ServerSelectionSheet.show(
                        context,
                        onSelected: (server) => _onServerSelected(ref, server),
                      );
                    } else {
                      ServerChangeBlockedDialog.show(context);
                    }
                  },
                ),
              ),
              SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusChip(
                      label: _chipLabel(state, elapsed),
                      dotColor: _dotColor(state),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    SizedBox(
                      width: 260,
                      child: Text(
                        _caption(state),
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space6,
                ),
                child: Column(
                  children: [
                    _buildConnectButton(state, controller),
                    const SizedBox(height: AppSpacing.space4),
                    _buildActionUnderButton(state, controller),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space4),
                child: state == HomeState.connected
                    ? TrafficStatsCard(traffic: traffic)
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _chipLabel(HomeState state, Duration elapsed) {
    switch (state) {
      case HomeState.disconnected:
        return AppStrings.stateDisconnectedChip;
      case HomeState.connecting:
        return AppStrings.stateConnectingChip;
      case HomeState.connected:
        return '${AppStrings.stateConnectedChipPrefix} · '
            '${formatElapsed(elapsed)}';
      case HomeState.failed:
        return AppStrings.stateFailedChip;
    }
  }

  Color _dotColor(HomeState state) {
    switch (state) {
      case HomeState.disconnected:
        return AppColors.textSecondary;
      case HomeState.connecting:
        return AppColors.primary;
      case HomeState.connected:
        return AppColors.success;
      case HomeState.failed:
        return AppColors.error;
    }
  }

  String _caption(HomeState state) {
    switch (state) {
      case HomeState.disconnected:
        return AppStrings.stateDisconnectedCaption;
      case HomeState.connecting:
        return AppStrings.stateConnectingCaption;
      case HomeState.connected:
        return AppStrings.stateConnectedCaption;
      case HomeState.failed:
        return AppStrings.stateFailedCaption;
    }
  }

  Widget _buildConnectButton(HomeState state, VpnController controller) {
    switch (state) {
      case HomeState.disconnected:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.surface,
          strokeColor: AppColors.border,
          iconColor: AppColors.textSecondary,
          onTap: controller.connect,
        );
      case HomeState.connecting:
        return ConnectButton(
          icon: LucideIcons.loader,
          fillColor: AppColors.primary,
          strokeColor: AppColors.primary,
          iconColor: AppColors.primaryOn,
          isBusy: true,
          onTap: null,
        );
      case HomeState.connected:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.primary,
          strokeColor: AppColors.primary,
          iconColor: AppColors.primaryOn,
          onTap: controller.disconnect,
        );
      case HomeState.failed:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.surface,
          strokeColor: AppColors.error,
          iconColor: AppColors.error,
          onTap: controller.connect,
        );
    }
  }

  Widget _buildActionUnderButton(HomeState state, VpnController controller) {
    switch (state) {
      case HomeState.disconnected:
        return Text(AppStrings.actionConnect, style: AppTypography.bodyStrong);
      case HomeState.connecting:
        return SecondaryButton(
          label: AppStrings.actionCancel,
          onPressed: controller.disconnect,
        );
      case HomeState.connected:
        return Text(
          AppStrings.actionDisconnect,
          style: AppTypography.bodyStrong,
        );
      case HomeState.failed:
        return Text(AppStrings.actionRetry, style: AppTypography.bodyStrong);
    }
  }
}

