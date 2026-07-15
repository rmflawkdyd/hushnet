import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/traffic_speed_calculator.dart';
import '../../data/models/vpn_traffic.dart';
import '../../data/models/wireguard_config.dart';
import '../../data/repositories/device_key_store.dart';
import '../../data/repositories/registration_repository.dart';
import '../../data/repositories/registration_vpn_config_repository.dart';
import '../../data/repositories/vpn_config_repository.dart';
import '../../domain/services/connection_config_builder.dart';
import '../../domain/entities/vpn_connection_status.dart';
import '../../domain/services/vpn_service.dart';
import '../../resources/strings/app_strings.dart';
import 'server_selection_controller.dart';

final vpnServiceProvider = Provider<VpnService>((ref) => VpnService());

final vpnStatusProvider = StreamProvider<VpnConnectionStatus>((ref) {
  return ref.watch(vpnServiceProvider).statusStream;
});

/// 연결됨 상태에서 실시간 트래픽(속도·경과시간)을 방출한다.
final vpnTrafficProvider = StreamProvider<VpnTraffic>((ref) {
  final speedCalculator = TrafficSpeedCalculator();
  return ref
      .watch(vpnServiceProvider)
      .trafficStream
      .map((snapshot) => speedCalculator.addSnapshot(snapshot, DateTime.now()));
});

const String _nodeBaseUrl = String.fromEnvironment('HUSHNET_NODE_BASE_URL');

final vpnConfigRepositoryProvider = Provider<VpnConfigRepository>((ref) {
  return RegistrationVpnConfigRepository(
    serverDirectoryRepository: ref.watch(serverDirectoryRepositoryProvider),
    connectionConfigBuilder: ConnectionConfigBuilder(
      deviceKeyStore: DeviceKeyStore(),
      registrationRepository: HttpRegistrationRepository(
        nodeBaseUrl: _nodeBaseUrl,
      ),
    ),
    selectedServerId: () => ref.read(selectedServerIdProvider.future),
  );
});

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

  /// 다른 서버를 고르면 기존 터널을 끊고 새 서버로 다시 연결한다 (PM 3장 분기).
  Future<void> reconnect() async {
    await _service.disconnect();
    await connect();
  }
}

final vpnControllerProvider = NotifierProvider<VpnController, String?>(
  VpnController.new,
);
