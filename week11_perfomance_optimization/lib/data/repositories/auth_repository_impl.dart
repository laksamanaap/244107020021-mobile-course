import 'package:dio/dio.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_errors.dart';

/// Login ke Laravel Sanctum kalau [dio] diisi.
/// Tanpa [dio] tetap mock — dipakai unit/widget test.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({Dio? this._dio});

  final Dio? _dio;

  @override
  bool get usesLiveApi => _dio != null;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final dio = _dio;
    if (dio == null) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@') || password.length < 6) {
        throw Exception('Email atau kata sandi tidak valid');
      }
      return AuthSession(
        access: 'mock-access-for-$email',
        refresh: 'mock-refresh-for-$email',
        user: AuthUser(id: 1, name: 'Mock Mahasiswa', email: email),
      );
    }

    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/login',
        data: {'email': email, 'password': password},
      );
      final data = Map<String, dynamic>.from(res.data ?? const {});
      final token = data['token']?.toString() ?? '';
      if (token.isEmpty) {
        throw Exception('Login gagal. Token kosong.');
      }
      final userJson = data['user'];
      return AuthSession(
        access: token,
        refresh: '',
        user: userJson is Map<String, dynamic>
            ? AuthUser.fromJson(userJson)
            : null,
      );
    } on DioException catch (error) {
      throw Exception(messageFromDio(error));
    }
  }

  @override
  Future<AuthUser> me() async {
    final dio = _dio;
    if (dio == null) {
      return const AuthUser(
        id: 1,
        name: 'Mock Mahasiswa',
        email: 'mahasiswa@jti.polinema.ac.id',
      );
    }
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/me');
      final data = Map<String, dynamic>.from(res.data ?? const {});
      final userJson = data['user'];
      if (userJson is Map<String, dynamic>) {
        return AuthUser.fromJson(userJson);
      }
      throw Exception('Sesi tidak valid.');
    } on DioException catch (error) {
      throw Exception(messageFromDio(error));
    }
  }

  @override
  Future<void> logout() async {
    final dio = _dio;
    if (dio == null) return;
    try {
      await dio.post<Map<String, dynamic>>('/api/logout');
    } on DioException {
      // Token lokal tetap dihapus di AuthNotifier meski API gagal.
    }
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
