import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/note_repository.dart';

// SEMENTARA: repository lama masih dipakai khusus cache posts.
// Dirapikan pada Refactoring Challenge (fitur cache posts).
final postCacheRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Map<String, dynamic>>>(
        CachedPostsNotifier.new);

class CachedPostsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repository = ref.watch(postCacheRepositoryProvider);
    final cached = await repository.readCachedPosts();
    _refreshInBackground(repository);

    return cached;
  }

  Future<void> _refreshInBackground(NoteRepository repository) async {
    try {
      final freshPosts = await repository.fetchPostsFromNetwork();
      await repository.saveCachedPosts(freshPosts);
      ref.invalidateSelf();
    } catch (_) {
      // Gagal refresh (misal tidak ada internet) dibiarkan diam-diam;
      // data cache yang sudah ditampilkan tetap valid untuk dipakai.
    }
  }
}
