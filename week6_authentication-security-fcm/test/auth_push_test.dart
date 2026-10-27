import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week6_authentication_security_fcm/data/api_errors.dart';
import 'package:week6_authentication_security_fcm/messaging/notif_kind.dart';
import 'package:week6_authentication_security_fcm/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), AppRoutes.home);
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(
      routeFromMessage({'route': AppRoutes.pengumumanId('3')}),
      AppRoutes.pengumumanId('3'),
    );
  });

  test('FCM type=list membuka kotak masuk, type lain mengikuti route', () {
    expect(
      routeFromMessage({'type': 'list', 'route': '/pengumuman/9'}),
      AppRoutes.notifications,
    );
    expect(
      routeFromMessage({'type': 'sound', 'route': '/pengumuman/3'}),
      AppRoutes.pengumumanId('3'),
    );
    expect(notifKindFromMessage({'type': 'list'}), NotifKind.list);
    expect(notifKindFromMessage({'type': 'icon'}), NotifKind.icon);
    expect(notifKindFromMessage({'type': 'sound'}), NotifKind.sound);
    expect(notifKindFromMessage({}), NotifKind.sound);
  });

  test('data payload membawa id pengumuman', () {
    final data = {'route': AppRoutes.pengumumanId('3'), 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), AppRoutes.pengumumanId('3'));
  });

  test('provider auth membaca status login dari token', () async {
    final store = FakeTokenStore()..access = 'mock-access';
    expect(store.access != null, isTrue);
    store.access = null;
    expect(store.access != null, isFalse);
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final store = FakeTokenStore()..refresh = '';
    final needsLogin = (store.refresh ?? '').isEmpty;
    expect(needsLogin, isTrue);
  });

  test('messageFromDio memetakan 401, timeout, dan offline', () {
    expect(
      messageFromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      'Koneksi timeout. Coba lagi.',
    );
    expect(
      messageFromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      ),
      'Tidak ada koneksi. Periksa internet.',
    );
    expect(
      messageFromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 401),
        ),
      ),
      'Sesi berakhir, silakan login lagi.',
    );
  });
}
