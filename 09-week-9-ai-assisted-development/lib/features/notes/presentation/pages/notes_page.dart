import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_result_list.dart';
import '../widgets/notes_search_field.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                final result = await ref.read(syncNotesProvider).call();
                ref.invalidate(notesProvider);
                ref.invalidate(dirtyCountProvider);
                if (context.mounted) {
                  final message = result.failure?.message ??
                      '${result.synced} catatan berhasil disinkron';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: NotesSearchField(),
          ),
          Expanded(
            child: NotesResultList(
              itemBuilder: (context, note) => NoteTile(
                note: note,
                onDelete: () =>
                    ref.read(notesProvider.notifier).deleteNote(note.id!),
                onTap: () => context.push('/note/${note.id}'),
              ),
            ),
          ),
        ],
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