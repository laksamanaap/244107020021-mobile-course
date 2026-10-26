import 'package:flutter_test/flutter_test.dart';
import 'package:week6_authentication_security_fcm/messaging/message_route.dart';

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('payload uji lokal mengarah ke halaman pengumuman', () {
    expect(
      routeFromMessage({'route': '/pengumuman/lokal'}),
      '/pengumuman/lokal',
    );
  });
}
