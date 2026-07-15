class RegistrationRequest {
  const RegistrationRequest({
    required this.serverId,
    required this.clientPublicKey,
    this.attestationToken,
  });

  final String serverId;
  final String clientPublicKey;
  final String? attestationToken;

  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'clientPublicKey': clientPublicKey,
      if (attestationToken != null) 'attestationToken': attestationToken,
    };
  }
}

class RegistrationResponse {
  const RegistrationResponse({
    required this.assignedAddress,
    required this.dns,
    required this.keyVersion,
    this.presharedKey,
  });

  final String assignedAddress;
  final String dns;
  final int keyVersion;
  final String? presharedKey;

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      assignedAddress: json['assignedAddress'] as String,
      dns: json['dns'] as String,
      keyVersion: json['keyVersion'] as int,
      presharedKey: json['presharedKey'] as String?,
    );
  }
}

enum RegistrationFailureReason {
  attestationRejected,
  rateLimited,
  serverUnavailable,
  network,
  unknown,
}

class RegistrationException implements Exception {
  const RegistrationException(this.reason, [this.statusCode]);

  final RegistrationFailureReason reason;
  final int? statusCode;

  static RegistrationFailureReason reasonForStatus(int statusCode) {
    switch (statusCode) {
      case 403:
        return RegistrationFailureReason.attestationRejected;
      case 429:
        return RegistrationFailureReason.rateLimited;
      case 503:
        return RegistrationFailureReason.serverUnavailable;
      default:
        return RegistrationFailureReason.unknown;
    }
  }

  @override
  String toString() => 'RegistrationException(${reason.name}, $statusCode)';
}
