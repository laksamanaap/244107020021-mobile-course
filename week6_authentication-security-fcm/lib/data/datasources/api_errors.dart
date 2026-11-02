import 'package:dio/dio.dart';

/// UI hanya terima string ramah, bukan DioException mentah.
String messageFromDio(Object error) {
  if (error is! DioException) {
    return 'Permintaan gagal. Coba lagi.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi timeout. Coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi. Periksa internet.';
    default:
      break;
  }

  final code = error.response?.statusCode;
  final path = error.requestOptions.path;
  final serverMessage = _serverMessage(error);

  if (code == 401) {
    if (path.contains('/login')) {
      return serverMessage ?? 'Email atau kata sandi salah.';
    }
    return 'Sesi berakhir, silakan login lagi.';
  }
  if (code == 422) {
    return serverMessage ?? 'Email atau kata sandi tidak valid.';
  }
  if (code == 403) {
    return 'Akses ditolak.';
  }
  return serverMessage ?? 'Permintaan gagal. Coba lagi.';
}

String? _serverMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['message'] is String) {
    final message = (data['message'] as String).trim();
    if (message.isNotEmpty) return message;
  }
  return null;
}
