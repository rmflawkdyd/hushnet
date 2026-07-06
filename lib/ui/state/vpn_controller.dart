import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/wireguard_config.dart';
import '../../data/repositories/bundled_vpn_config.dart';
import '../../data/repositories/static_vpn_config_repository.dart';
import '../../data/repositories/vpn_config_repository.dart';
import '../../domain/entities/vpn_connection_status.dart';
import '../../domain/services/vpn_service.dart';
import '../../resources/strings/app_strings.dart';

final vpnServiceProvider = Provider<VpnService>((ref) => VpnService());

final vpnStatusProvider = StreamProvider<VpnConnectionStatus>((ref) {
  return ref.watch(vpnServiceProvider).statusStream;
});

final vpnConfigRepositoryProvider = Provider<VpnConfigRepository>(
  (ref) => const StaticVpnConfigRepository(
    bundledConfig: hushnetBundledConfigIsReady ? hushnetBundledConfig : null,
  ),
);

class VpnController extends Notifier<String?> {
  @override
  String? build() => null;

  VpnService get _service => ref.read(vpnServiceProvider);
  VpnConfigRepository get _configRepository =>
      ref.read(vpnConfigRepositoryProvider);

  Future<void> connect() async {
    WireGuardConfig? config;
    try {
      config = await _configRepository.getConfig();
    } catch (_) {
      state = AppStrings.connectFailed;
      return;
    }
    if (config == null) {
      state = AppStrings.noConfig;
      return;
    }
    state = null;
    try {
      await _service.connect(config);
    } catch (_) {
      state = AppStrings.connectFailed;
    }
  }

  Future<void> disconnect() async {
    state = null;
    try {
      await _service.disconnect();
    } catch (_) {
      state = AppStrings.disconnectFailed;
    }
  }
}

final vpnControllerProvider = NotifierProvider<VpnController, String?>(
  VpnController.new,
);
