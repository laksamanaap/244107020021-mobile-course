import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/token_store.dart';

/// Token di Android Keystore (AES-GCM). Bukan SharedPreferences.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
          );

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// Penyimpanan memori untuk unit test interceptor (bukan Keystore).
class MemoryTokenStore implements TokenStore {
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
