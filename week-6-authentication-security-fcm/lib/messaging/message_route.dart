/// Parsing murni `data.route` dari payload FCM. Bisa diuji tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route']?.toString().trim() ?? '';
  if (raw.isEmpty) return '/';
  return raw.startsWith('/') ? raw : '/$raw';
}
