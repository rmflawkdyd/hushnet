class WireGuardKeyPair {
  const WireGuardKeyPair({
    required this.privateKeyBase64,
    required this.publicKeyBase64,
  });

  final String privateKeyBase64;

  final String publicKeyBase64;
}
