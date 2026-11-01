import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(),
);

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
      CachedPostsNotifier.new,
    );

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final cached = await repository.readCached();
    if (cached.failure != null) throw FailureException(cached.failure!);

    _refreshInBackground(repository);
    return cached.posts;
  }

  Future<void> _refreshInBackground(PostRepository repository) async {
    final result = await repository.refresh();
    // Gagal refresh (misal tidak ada internet) dibiarkan diam-diam;
    // data cache yang sudah tampil tetap valid.
    if (result.failure != null && result.posts.isEmpty) return;
    state = AsyncData(result.posts);
  }
}
