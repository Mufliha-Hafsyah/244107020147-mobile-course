import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

final commentDioProvider = Provider<Dio>((ref) => createDio());

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(commentDioProvider)),
);

/// FutureProvider.family menghasilkan satu provider terpisah untuk
/// setiap nilai postId yang berbeda, dan otomatis membungkus hasilnya
/// sebagai AsyncValue (loading/error/data) tanpa perlu class Notifier
/// khusus, karena datanya hanya dibaca sekali (tidak ada aksi refresh
/// manual seperti pada postListProvider).
final commentsProvider = FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

/// Menerjemahkan error teknis menjadi pesan yang ramah pengguna.
String commentErrorMessage(Object error) {
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
        if (code == 404) return 'Komentar tidak ditemukan.';
        return 'Server bermasalah ($code).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return 'Terjadi kesalahan tak terduga.';
}