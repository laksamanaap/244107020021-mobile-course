import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

const _retriedKey = 'auth_retried';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
  dio.httpClientAdapter = adapter ?? CampusMockAdapter();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final alreadyRetried = e.requestOptions.extra[_retriedKey] == true;
        if (e.response?.statusCode == 401 && !alreadyRetried) {
          final refresh = await store.readRefresh();
          if (refresh == null || refresh.isEmpty) {
            await store.clear();
            await onSessionExpired?.call();
            return handler.next(e);
          }
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            e.requestOptions.headers['Authorization'] = 'Bearer $renewed';
            e.requestOptions.extra[_retriedKey] = true;
            final retry = await dio.fetch(e.requestOptions);
            return handler.resolve(retry);
          } catch (_) {
            await store.clear();
            await onSessionExpired?.call();
          }
        }
        handler.next(e);
      },
    ),
  );
  return dio;
}

/// Adapter simulasi: tidak ada backend sungguhan di praktikum ini.
/// Request pertama ke /protected memakai access token awal → 401,
/// retry setelah refresh → 200.
class CampusMockAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final auth = options.headers['Authorization']?.toString() ?? '';
    final retried = options.extra[_retriedKey] == true;

    if (path.endsWith('/protected')) {
      final expiredOriginal =
          auth.contains('mock-access-for-') && !auth.contains('renewed');
      if (expiredOriginal && !retried) {
        return _json(401, {'error': 'token_expired'});
      }
      return _json(200, {
        'ok': true,
        'source': 'mock',
        'authorized': auth.startsWith('Bearer '),
      });
    }

    return _json(200, {'ok': true, 'source': 'mock', 'path': path});
  }

  ResponseBody _json(int status, Map<String, Object?> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class CampusApi {
  CampusApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchProtected() async {
    final res = await _dio.get<Map<String, dynamic>>('/protected');
    return Map<String, dynamic>.from(res.data ?? const {});
  }
}
