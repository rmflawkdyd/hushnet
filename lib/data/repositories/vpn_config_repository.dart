import '../models/wireguard_config.dart';

abstract class VpnConfigRepository {
  Future<WireGuardConfig?> getConfig();
}
