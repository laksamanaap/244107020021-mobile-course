import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Satu-satunya pintu masuk/keluar token. Jangan simpan token di SharedPreferences.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // v11+ memakai AES-GCM + Android Keystore (pengganti
            // encryptedSharedPreferences yang sudah dihapus).
            aOptions: AndroidOptions(),
          );

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);

  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> clear() => _storage.deleteAll();
}

/// Penyimpanan memori untuk unit test interceptor (bukan Keystore).
class MemoryTokenStore extends TokenStore {
  MemoryTokenStore() : super(storage: const FlutterSecureStorage());

  String? access;
  String? refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}
