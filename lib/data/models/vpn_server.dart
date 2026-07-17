enum VpnServerStatus {
  active,
  full,
  down;

  static VpnServerStatus fromName(String? name) {
    return VpnServerStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => VpnServerStatus.active,
    );
  }
}

class VpnServer {
  const VpnServer({
    required this.id,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.endpoint,
    required this.registerUrl,
    required this.serverPublicKey,
    required this.dns,
    required this.allowedIps,
    required this.keyVersion,
    required this.status,
  });

  final String id;
  final String country;
  final String countryCode;
  final String city;
  final String endpoint;
  final String registerUrl;
  final String serverPublicKey;
  final String dns;
  final String allowedIps;
  final int keyVersion;
  final VpnServerStatus status;

  bool get isSelectable => status == VpnServerStatus.active;

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String,
      city: json['city'] as String,
      endpoint: json['endpoint'] as String,
      registerUrl: json['registerUrl'] as String,
      serverPublicKey: json['serverPublicKey'] as String,
      dns: json['dns'] as String,
      allowedIps: json['allowedIps'] as String,
      keyVersion: json['keyVersion'] as int,
      status: VpnServerStatus.fromName(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'countryCode': countryCode,
      'city': city,
      'endpoint': endpoint,
      'registerUrl': registerUrl,
      'serverPublicKey': serverPublicKey,
      'dns': dns,
      'allowedIps': allowedIps,
      'keyVersion': keyVersion,
      'status': status.name,
    };
  }
}
