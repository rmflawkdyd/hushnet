import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../data/models/wireguard_key_pair.dart';

class WireGuardKeyGenerator {
  const WireGuardKeyGenerator();

  Future<WireGuardKeyPair> generate() async {
    final keyPair = await X25519().newKeyPair();

    final privateKeyBytes = Uint8List.fromList(
      await keyPair.extractPrivateKeyBytes(),
    );
    _clampToWireGuardScalar(privateKeyBytes);

    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = Uint8List.fromList(publicKey.bytes);

    return WireGuardKeyPair(
      privateKeyBase64: base64.encode(privateKeyBytes),
      publicKeyBase64: base64.encode(publicKeyBytes),
    );
  }

  void _clampToWireGuardScalar(Uint8List key) {
    key[0] &= 248;
    key[31] &= 127;
    key[31] |= 64;
  }
}
