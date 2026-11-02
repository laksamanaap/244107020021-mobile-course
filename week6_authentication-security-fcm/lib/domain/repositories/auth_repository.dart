import '../entities/auth_session.dart';

/// Kontrak auth. Presentation tergantung ini, bukan Dio.
abstract class AuthRepository {
  bool get usesLiveApi;

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthUser> me();

  Future<void> logout();

  Future<String> refresh(String refreshToken);
}
