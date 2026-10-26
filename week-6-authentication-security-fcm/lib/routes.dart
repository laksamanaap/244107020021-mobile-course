/// Rute GoRouter dan deep link FCM memakai konstanta yang sama.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const pengumuman = '/pengumuman/:id';

  static String pengumumanId(String id) => '/pengumuman/$id';
}

/// Parsing murni `data.route` dari payload FCM. Bisa diuji tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route']?.toString().trim() ?? '';
  if (raw.isEmpty) return AppRoutes.home;
  return raw.startsWith('/') ? raw : '/$raw';
}
