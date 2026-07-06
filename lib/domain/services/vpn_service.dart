import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

import '../../data/models/wireguard_config.dart';
import '../entities/vpn_connection_status.dart';

class VpnService {
  final _wireguard = WireGuardFlutter.instance;
  bool _initialized = false;

  Stream<VpnConnectionStatus> get statusStream =>
      _wireguard.vpnStageSnapshot.map(VpnConnectionStatusX.fromStage);

  Stream<Map<String, dynamic>> get trafficStream => _wireguard.trafficSnapshot;

  Future<void> initialize({
    String? iosAppGroup,
    String? extensionBundleId,
  }) async {
    if (_initialized) return;
    await _wireguard.initialize(
      interfaceName: 'hushnet',
      vpnName: 'Hushnet',
      iosAppGroup: iosAppGroup,
      extensionBundleId: extensionBundleId,
    );
    _initialized = true;
  }

  Future<bool> hasPermission() => _wireguard.checkVpnPermission();

  Future<void> connect(WireGuardConfig config) async {
    await initialize();
    await _wireguard.startVpn(
      serverAddress: config.serverAddress,
      wgQuickConfig: config.wgQuickConfig,
      providerBundleIdentifier: config.providerBundleIdentifier,
    );
  }

  Future<void> disconnect() => _wireguard.stopVpn();

  Future<VpnConnectionStatus> currentStatus() async =>
      VpnConnectionStatusX.fromStage(await _wireguard.stage());
}
