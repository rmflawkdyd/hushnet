import '../../data/models/server_registration.dart';
import '../../data/models/vpn_server.dart';
import '../../data/models/wireguard_config.dart';
import '../../data/repositories/device_key_store.dart';
import '../../data/repositories/registration_repository.dart';
import 'attestation_service.dart';
import 'wireguard_config_assembler.dart';

class ConnectionConfigBuilder {
  ConnectionConfigBuilder({
    required DeviceKeyStore deviceKeyStore,
    required RegistrationRepository registrationRepository,
    AttestationProvider attestationProvider = const NoopAttestationProvider(),
    WireGuardConfigAssembler assembler = const WireGuardConfigAssembler(),
  }) : _deviceKeyStore = deviceKeyStore,
       _registrationRepository = registrationRepository,
       _attestationProvider = attestationProvider,
       _assembler = assembler;

  final DeviceKeyStore _deviceKeyStore;
  final RegistrationRepository _registrationRepository;
  final AttestationProvider _attestationProvider;
  final WireGuardConfigAssembler _assembler;

  Future<WireGuardConfig> buildFor(VpnServer server) async {
    final keyPair = await _deviceKeyStore.loadOrCreate();
    final attestationToken = await _attestationProvider.requestAttestationToken();

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
