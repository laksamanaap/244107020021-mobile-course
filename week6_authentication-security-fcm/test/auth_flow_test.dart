import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week6_authentication_security_fcm/data/api_client.dart';
import 'package:week6_authentication_security_fcm/data/auth_repository.dart';
import 'package:week6_authentication_security_fcm/data/token_store.dart';
import 'package:week6_authentication_security_fcm/providers/auth_provider.dart';

void main() {
  test('TokenStore menyimpan, membaca, dan menghapus token', () async {
    final store = MemoryTokenStore();
    await store.save(access: 'acc', refresh: 'ref');
    expect(await store.readAccess(), 'acc');
    expect(await store.readRefresh(), 'ref');
    await store.clear();
    expect(await store.readAccess(), isNull);
    expect(await store.readRefresh(), isNull);
  });

  test('login mock valid mengembalikan token simulasi', () async {
    final repo = AuthRepository();
    final session = await repo.login(email: 'a@b.c', password: '123456');
    expect(session.access, contains('mock-access-for-a@b.c'));
    expect(session.refresh, contains('mock-refresh-for-a@b.c'));
  });

  test('login mock menolak kredensial tidak valid', () async {
    final repo = AuthRepository();
    expect(
      () => repo.login(email: 'salah', password: '123'),
      throwsA(isA<Exception>()),
    );
  });

  test('refresh token kosong gagal', () async {
    expect(() => AuthRepository().refresh(''), throwsA(isA<Exception>()));
  });

  test('request memakai Bearer dan HTTP 401 memicu refresh sekali', () async {
    final store = MemoryTokenStore();
    await store.save(
      access: 'mock-access-for-a@b.c',
      refresh: 'mock-refresh-for-a@b.c',
    );
    final spy = _HeaderSpyAdapter(CampusMockAdapter());
    var expired = 0;
    final dio = buildApiClient(
      store,
      AuthRepository(),
      onSessionExpired: () async => expired++,
      adapter: spy,
    );

    final res = await dio.get<Map<String, dynamic>>('/protected');
    expect(res.statusCode, 200);
    expect(res.data?['ok'], true);
    expect(res.data?['authorized'], true);
    expect(spy.authorization, hasLength(2));
    expect(spy.authorization.first, 'Bearer mock-access-for-a@b.c');
    expect(spy.authorization.last, startsWith('Bearer mock-access-renewed-'));
    expect(store.access, contains('mock-access-renewed-'));
    expect(expired, 0);
  });

  test('request kedua tidak 401 berulang setelah access diperbarui', () async {
    final store = MemoryTokenStore();
    await store.save(
      access: 'mock-access-for-a@b.c',
      refresh: 'mock-refresh-for-a@b.c',
    );
    final spy = _HeaderSpyAdapter(CampusMockAdapter());
    final dio = buildApiClient(store, AuthRepository(), adapter: spy);
    await dio.get('/protected');
    final renewed = store.access;
    final res = await dio.get('/protected');
    expect(res.statusCode, 200);
    expect(store.access, renewed);
    expect(spy.authorization, hasLength(3));
    expect(spy.authorization[0], 'Bearer mock-access-for-a@b.c');
    expect(spy.authorization[1], startsWith('Bearer mock-access-renewed-'));
    expect(spy.authorization[2], 'Bearer $renewed');
  });

  test('retry setelah 401 maksimal sekali', () async {
    final store = MemoryTokenStore();
    await store.save(access: 'acc', refresh: 'ref');
    final adapter = _Always401Adapter();
    final dio = buildApiClient(store, AuthRepository(), adapter: adapter);

    await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));
    expect(adapter.fetches, 2);
  });

  test('refresh hilang mengakhiri sesi', () async {
    final store = MemoryTokenStore();
    await store.save(access: 'mock-access-for-a@b.c', refresh: '');
    var expired = 0;
    final adapter = _Always401Adapter();
    final dio = buildApiClient(
      store,
      AuthRepository(),
      onSessionExpired: () async => expired++,
      adapter: adapter,
    );

    await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));
    expect(adapter.fetches, 1);
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(expired, 1);
  });

  test('logout Riverpod membersihkan token dan status', () async {
    final store = MemoryTokenStore();
    await store.save(access: 'acc', refresh: 'ref');
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(await container.read(authStateProvider.future), isTrue);
    await container.read(authStateProvider.notifier).logout();
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(await container.read(authStateProvider.future), isFalse);
  });
}

class _HeaderSpyAdapter implements HttpClientAdapter {
  _HeaderSpyAdapter(this._inner);

  final HttpClientAdapter _inner;
  final List<String> authorization = [];

  @override
  void close({bool force = false}) => _inner.close(force: force);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    authorization.add(options.headers['Authorization']?.toString() ?? '');
    return _inner.fetch(options, requestStream, cancelFuture);
  }
}

class _Always401Adapter implements HttpClientAdapter {
  int fetches = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetches++;
    return ResponseBody.fromString(
      '{"error":"unauthorized"}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
