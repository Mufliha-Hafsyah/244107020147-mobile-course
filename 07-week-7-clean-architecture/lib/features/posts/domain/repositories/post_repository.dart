import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  /// Membaca posts dari cache lokal.
  Future<({List<Post> posts, Failure? failure})> readCached();

  /// Mengambil posts terbaru dari jaringan lalu menyimpannya ke cache.
  Future<({List<Post> posts, Failure? failure})> refresh();
}