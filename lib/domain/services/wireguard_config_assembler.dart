import '../../core/ios_vpn_config.dart';
import '../../data/models/server_registration.dart';
import '../../data/models/vpn_server.dart';
import '../../data/models/wireguard_config.dart';
import '../../data/models/wireguard_key_pair.dart';

class WireGuardConfigAssembler {
  const WireGuardConfigAssembler();

  WireGuardConfig assemble({
    required VpnServer server,
    required WireGuardKeyPair keyPair,
    required RegistrationResponse registration,
  }) {
    final config = StringBuffer()
      ..writeln('[Interface]')
      ..writeln('PrivateKey = ${keyPair.privateKeyBase64}')
      ..writeln('Address = ${registration.assignedAddress}')
      ..writeln('DNS = ${registration.dns}')
      ..writeln()
      ..writeln('[Peer]')
      ..writeln('PublicKey = ${server.serverPublicKey}');

    final presharedKey = registration.presharedKey;
    if (presharedKey != null && presharedKey.isNotEmpty) {
      config.writeln('PresharedKey = $presharedKey');
    }

    config
      ..writeln('Endpoint = ${server.endpoint}')
      ..writeln('AllowedIPs = ${server.allowedIps}');

    return WireGuardConfig(
      name: server.country,
      serverAddress: server.endpoint,
      wgQuickConfig: config.toString(),
      providerBundleIdentifier: IosVpnConfig.extensionBundleId,
    );
  }
}
