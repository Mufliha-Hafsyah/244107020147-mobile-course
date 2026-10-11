import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import 'widgets/note_tile.dart';
import 'package:go_router/go_router.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repository = ref.watch(noteRepositoryProvider);
    return repository.fetchNotes();
  }

  Future<void> addNote(String title) async {
    await ref.read(noteRepositoryProvider).addNote(title: title);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider); // rebuild otomatis saat notes berubah
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Catatan'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () async {
              final repository = ref.read(noteRepositoryProvider);
              final synced = await syncNotes(repository);
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$synced catatan berhasil disinkron')),
                );
              }
            },
          ),
          dirtyCountAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Chip(label: Text('Belum sinkron: $count')),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan.'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteTile(
                    note: note,
                    onDelete: () =>
                        ref.read(notesProvider.notifier).deleteNote(note.id!),
                    onTap: () => context.push('/note/${note.id}'),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(notesProvider.notifier).addNote(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}