/// Satu-satunya pintu token. Implementasi ada di data layer (Keystore).
abstract class TokenStore {
  Future<void> save({required String access, required String refresh});

  Future<String?> readAccess();

  Future<String?> readRefresh();

  Future<void> clear();
}
