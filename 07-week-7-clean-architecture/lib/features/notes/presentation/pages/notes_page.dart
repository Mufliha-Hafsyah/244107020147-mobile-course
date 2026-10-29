import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';
import '../../../../core/failures.dart';

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
              final result = await ref.read(syncNotesProvider).call();
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
              if (context.mounted) {
                final message =
                    result.failure?.message ??
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
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(messageFromError(err))),
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
    String? errorText;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Catatan baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(errorText: errorText), // Menampilkan error
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final error = await ref
                    .read(notesProvider.notifier)
                    .addNote(controller.text);
                
                if (error != null) {
                  setState(() => errorText = error);
                  return;
                }
                
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
