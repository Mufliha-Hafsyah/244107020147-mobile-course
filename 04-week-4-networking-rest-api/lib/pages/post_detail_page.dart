import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';
import 'package:go_router/go_router.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({required this.postId, super.key});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coba ambil dari list yang sudah dimuat sebelumnya (menghindari
    // request tambahan jika data sudah tersedia di memori).
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(friendlyErrorMessage(err))),
        data: (posts) {
          // Cari post dengan id yang cocok dari list yang sudah dimuat.
          final post = posts.where((p) => p.id == postId).cast<Post?>().firstWhere(
                (p) => p != null,
                orElse: () => null,
              );

          if (post == null) {
            return const Center(
              child: Text('Post tidak ditemukan dalam data yang sudah dimuat.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}