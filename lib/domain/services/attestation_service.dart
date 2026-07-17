import 'package:flutter/foundation.dart';

abstract class AttestationProvider {
  Future<String?> requestAttestationToken();
}

class NoopAttestationProvider implements AttestationProvider {
  const NoopAttestationProvider();

  @override
  Future<String?> requestAttestationToken() async => null;
}

class StaticAttestationProvider implements AttestationProvider {
  const StaticAttestationProvider(this.token);

  final String token;

  @override
  Future<String?> requestAttestationToken() async => token;
}

class PlatformAttestationProvider implements AttestationProvider {
  const PlatformAttestationProvider();

  @override
  Future<String?> requestAttestationToken() async {
    throw UnimplementedError(
      'Platform attestation (Play Integrity / App Attest) is not implemented yet',
    );
  }
}

const _staticAttestationToken = String.fromEnvironment('HUSHNET_STATIC_TOKEN');

AttestationProvider createAttestationProvider() {
  if (kReleaseMode) {
    return const PlatformAttestationProvider();
  }
  if (_staticAttestationToken.isNotEmpty) {
    return const StaticAttestationProvider(_staticAttestationToken);
  }
  return const NoopAttestationProvider();
}
