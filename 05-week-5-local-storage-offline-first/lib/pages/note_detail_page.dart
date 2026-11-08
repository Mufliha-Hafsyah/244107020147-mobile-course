import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_page.dart'; // untuk akses notesProvider

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (notes) {
          final matches = notes.where((n) => n.id == noteId);
          if (matches.isEmpty) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          final note = matches.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(note.body),
                const SizedBox(height: 16),
                if (note.dirty) const Chip(label: Text('Belum tersinkron')),
              ],
            ),
          );
        },
      ),
    );
  }
}