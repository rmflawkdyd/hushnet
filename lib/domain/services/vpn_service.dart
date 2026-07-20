import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

import '../../core/ios_vpn_config.dart';
import '../../data/models/wireguard_config.dart';
import '../entities/vpn_connection_status.dart';

class VpnService {
  static const _permissionChannel = MethodChannel('hushnet/vpn_permission');

  final _wireguard = WireGuardFlutter.instance;
  bool _initialized = false;

  bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Stream<VpnConnectionStatus> get statusStream =>
      _wireguard.vpnStageSnapshot.map(VpnConnectionStatusX.fromStage);

  Stream<Map<String, dynamic>> get trafficStream => _wireguard.trafficSnapshot;

  Future<void> initialize() async {
    if (_initialized) return;
    await _wireguard.initialize(
      interfaceName: 'hushnet',
      vpnName: 'Hushnet',
      iosAppGroup: _isApplePlatform ? IosVpnConfig.appGroup : null,
      extensionBundleId:
          _isApplePlatform ? IosVpnConfig.extensionBundleId : null,
    );
    _initialized = true;
  }

  Future<bool> hasPermission() async {
    if (_isApplePlatform) {
      return true;
    }
    final granted =
        await _permissionChannel.invokeMethod<bool>('hasVpnPermission');
    return granted ?? false;
  }

  Future<bool> requestPermission() async {
    if (_isApplePlatform) {
      return true;
    }
    final granted =
        await _permissionChannel.invokeMethod<bool>('requestVpnPermission');
    return granted ?? false;
  }

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
