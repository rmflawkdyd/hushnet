import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/traffic_speed_calculator.dart';
import '../../data/models/vpn_traffic.dart';
import '../../data/models/wireguard_config.dart';
import '../../data/repositories/device_key_store.dart';
import '../../data/repositories/registration_repository.dart';
import '../../data/repositories/registration_vpn_config_repository.dart';
import '../../data/repositories/vpn_config_repository.dart';
import '../../domain/services/attestation_service.dart';
import '../../domain/services/connection_config_builder.dart';
import '../../domain/entities/vpn_connection_status.dart';
import '../../domain/services/vpn_service.dart';
import '../../resources/strings/app_strings.dart';
import 'server_selection_controller.dart';

final vpnServiceProvider = Provider<VpnService>((ref) => VpnService());

final vpnStatusProvider = StreamProvider<VpnConnectionStatus>((ref) {
  return ref.watch(vpnServiceProvider).statusStream;
});

/// 연결됨 상태에서 실시간 트래픽 속도를 방출한다.
final vpnTrafficProvider = StreamProvider<VpnTraffic>((ref) {
  final speedCalculator = TrafficSpeedCalculator();
  return ref
      .watch(vpnServiceProvider)
      .trafficStream
      .map((snapshot) => speedCalculator.addSnapshot(snapshot, DateTime.now()));
});

/// 연결 경과 시간을 로컬 타이머로 계산한다.
/// 트래픽 스냅샷과 분리되어, connected가 된 시각을 앵커로 매초 갱신한다.
/// 트래픽이 없거나 스냅샷이 늦어도 시간은 정상적으로 흐른다.
final connectionElapsedProvider = StreamProvider<Duration>((ref) {
  final isConnected = ref.watch(
    vpnStatusProvider.select(
      (status) => status.asData?.value == VpnConnectionStatus.connected,
    ),
  );
  if (!isConnected) {
    return Stream.value(Duration.zero);
  }
  final connectedAt = DateTime.now();
  return _connectionElapsedTicks(connectedAt);
});

Stream<Duration> _connectionElapsedTicks(DateTime connectedAt) async* {
  yield Duration.zero;
  yield* Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().difference(connectedAt),
  );
}

final vpnConfigRepositoryProvider = Provider<VpnConfigRepository>((ref) {
  return RegistrationVpnConfigRepository(
    serverDirectoryRepository: ref.watch(serverDirectoryRepositoryProvider),
    connectionConfigBuilder: ConnectionConfigBuilder(
      deviceKeyStore: DeviceKeyStore(),
      registrationRepository: HttpRegistrationRepository(),
      attestationProvider: createAttestationProvider(),
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
}

final vpnControllerProvider = NotifierProvider<VpnController, String?>(
  VpnController.new,
);
