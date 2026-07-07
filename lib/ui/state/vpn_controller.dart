import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vpn_traffic.dart';
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

/// 연결됨 상태에서 실시간 트래픽(속도·경과시간)을 방출한다.
final vpnTrafficProvider = StreamProvider<VpnTraffic>((ref) {
  return ref
      .watch(vpnServiceProvider)
      .trafficStream
      .map(VpnTraffic.fromSnapshot);
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
    } catch (e, st) {
      debugPrint('[HushnetDiag] getConfig failed: $e\n$st');
      state = AppStrings.connectFailed;
      return;
    }
    if (config == null) {
      debugPrint('[HushnetDiag] config is null (bundled config not ready)');
      state = AppStrings.noConfig;
      return;
    }
    debugPrint(
      '[HushnetDiag] config ready: name=${config.name} '
      'serverAddress=${config.serverAddress} '
      'wgLen=${config.wgQuickConfig.length}',
    );
    state = null;
    try {
      await _service.connect(config);
    } catch (e, st) {
      debugPrint('[HushnetDiag] connect failed: $e\n$st');
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
