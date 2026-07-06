import '../models/wireguard_config.dart';
import 'vpn_config_repository.dart';

class StaticVpnConfigRepository implements VpnConfigRepository {
  const StaticVpnConfigRepository({this.bundledConfig});

  final WireGuardConfig? bundledConfig;

  @override
  Future<WireGuardConfig?> getConfig() async => bundledConfig;
}
