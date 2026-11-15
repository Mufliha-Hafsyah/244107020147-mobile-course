import 'package:dio/dio.dart';

String friendlyAuthError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi lambat atau timeout. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Sesi berakhir, silakan login ulang.';
        return 'Server bermasalah ($code).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}