import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/notes_page.dart';
import 'repositories/note_repository.dart';

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Map<String, dynamic>>>(
        CachedPostsNotifier.new);

class CachedPostsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repository = ref.watch(noteRepositoryProvider);
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

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}