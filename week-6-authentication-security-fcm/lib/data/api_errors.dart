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
  if (code == 401) {
    return 'Sesi berakhir, silakan login lagi.';
  }
  return 'Permintaan gagal. Coba lagi.';
}
