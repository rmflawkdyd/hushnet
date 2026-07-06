import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

extension VpnConnectionStatusX on VpnConnectionStatus {
  static VpnConnectionStatus fromStage(VpnStage stage) {
    switch (stage) {
      case VpnStage.connected:
        return VpnConnectionStatus.connected;
      case VpnStage.connecting:
      case VpnStage.waitingConnection:
      case VpnStage.authenticating:
      case VpnStage.reconnect:
      case VpnStage.preparing:
        return VpnConnectionStatus.connecting;
      case VpnStage.disconnecting:
      case VpnStage.exiting:
        return VpnConnectionStatus.disconnecting;
      case VpnStage.denied:
        return VpnConnectionStatus.error;
      case VpnStage.disconnected:
      case VpnStage.noConnection:
        return VpnConnectionStatus.disconnected;
    }
  }
}
