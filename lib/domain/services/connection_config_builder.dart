import '../../data/models/server_registration.dart';
import '../../data/models/vpn_server.dart';
import '../../data/models/wireguard_config.dart';
import '../../data/repositories/device_key_store.dart';
import '../../data/repositories/registration_repository.dart';
import 'wireguard_config_assembler.dart';

class ConnectionConfigBuilder {
  ConnectionConfigBuilder({
    required DeviceKeyStore deviceKeyStore,
    required RegistrationRepository registrationRepository,
    WireGuardConfigAssembler assembler = const WireGuardConfigAssembler(),
  }) : _deviceKeyStore = deviceKeyStore,
       _registrationRepository = registrationRepository,
       _assembler = assembler;

  final DeviceKeyStore _deviceKeyStore;
  final RegistrationRepository _registrationRepository;
  final WireGuardConfigAssembler _assembler;

  Future<WireGuardConfig> buildFor(
    VpnServer server, {
    String? attestationToken,
  }) async {
    final keyPair = await _deviceKeyStore.loadOrCreate();

    final registration = await _registrationRepository.register(
      RegistrationRequest(
        serverId: server.id,
        clientPublicKey: keyPair.publicKeyBase64,
        attestationToken: attestationToken,
      ),
    );

    return _assembler.assemble(
      server: server,
      keyPair: keyPair,
      registration: registration,
    );
  }
}
