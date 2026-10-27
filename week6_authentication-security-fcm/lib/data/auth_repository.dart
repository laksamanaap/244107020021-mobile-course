import 'package:dio/dio.dart';

import 'api_errors.dart';

class AuthSession {
  const AuthSession({required this.access, required this.refresh, this.user});

  final String access;
  final String refresh;
  final AuthUser? user;
}

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

/// Login ke Laravel Sanctum kalau [dio] diisi.
/// Tanpa [dio] tetap mock — dipakai unit/widget test.
class AuthRepository {
  AuthRepository({Dio? this._dio});

  final Dio? _dio;

  bool get usesLiveApi => _dio != null;

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

  Future<void> logout() async {
    final dio = _dio;
    if (dio == null) return;
    try {
      await dio.post<Map<String, dynamic>>('/api/logout');
    } on DioException {
      // Token lokal tetap dihapus di AuthNotifier meski API gagal.
    }
  }

  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
