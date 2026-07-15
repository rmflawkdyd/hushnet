import '../../domain/services/wireguard_key_generator.dart';
import '../models/wireguard_key_pair.dart';
import 'secure_key_value_store.dart';

class DeviceKeyStore {
  DeviceKeyStore({
    SecureKeyValueStore? secureStore,
    WireGuardKeyGenerator? keyGenerator,
  }) : _secureStore = secureStore ?? FlutterSecureKeyValueStore(),
       _keyGenerator = keyGenerator ?? const WireGuardKeyGenerator();

  static const _privateKeyStorageKey = 'wg_client_private_key';
  static const _publicKeyStorageKey = 'wg_client_public_key';

  final SecureKeyValueStore _secureStore;
  final WireGuardKeyGenerator _keyGenerator;

  Future<WireGuardKeyPair>? _pendingLoadOrCreate;

  Future<WireGuardKeyPair> loadOrCreate() {
    return _pendingLoadOrCreate ??= _loadOrCreate();
  }

  Future<WireGuardKeyPair> _loadOrCreate() async {
    try {
      final existing = await _readExisting();
      return existing ?? await _generateAndStore();
    } catch (_) {
      _pendingLoadOrCreate = null;
      rethrow;
    }
  }

  Future<WireGuardKeyPair?> _readExisting() async {
    try {
      final privateKeyBase64 = await _secureStore.read(_privateKeyStorageKey);
      final publicKeyBase64 = await _secureStore.read(_publicKeyStorageKey);
      if (privateKeyBase64 == null || publicKeyBase64 == null) {
        return null;
      }
      return WireGuardKeyPair(
        privateKeyBase64: privateKeyBase64,
        publicKeyBase64: publicKeyBase64,
      );
    } catch (_) {
      await _deleteQuietly();
      return null;
    }
  }

  Future<WireGuardKeyPair> _generateAndStore() async {
    final keyPair = await _keyGenerator.generate();
    await _secureStore.write(_privateKeyStorageKey, keyPair.privateKeyBase64);
    await _secureStore.write(_publicKeyStorageKey, keyPair.publicKeyBase64);
    return keyPair;
  }

  Future<WireGuardKeyPair> resetKey() async {
    _pendingLoadOrCreate = null;
    await _deleteQuietly();
    return loadOrCreate();
  }

  Future<void> _deleteQuietly() async {
    try {
      await _secureStore.delete(_privateKeyStorageKey);
      await _secureStore.delete(_publicKeyStorageKey);
    } catch (_) {}
  }
}
