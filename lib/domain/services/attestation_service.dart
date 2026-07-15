import 'package:flutter/foundation.dart';

abstract class AttestationProvider {
  Future<String?> requestAttestationToken();
}

class NoopAttestationProvider implements AttestationProvider {
  const NoopAttestationProvider();

  @override
  Future<String?> requestAttestationToken() async => null;
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

AttestationProvider createAttestationProvider() {
  if (kReleaseMode) {
    return const PlatformAttestationProvider();
  }
  return const NoopAttestationProvider();
}
