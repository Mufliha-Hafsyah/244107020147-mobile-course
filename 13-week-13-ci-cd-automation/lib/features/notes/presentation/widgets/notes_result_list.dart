import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../../../../core/failures.dart';

class NotesResultList extends ConsumerWidget {
  const NotesResultList({super.key, this.itemBuilder});

  final Widget Function(BuildContext context, Note note)? itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(notesQueryProvider);
    return ref
        .watch(filteredNotesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(messageFromError(e))),
          data: (notes) {
            if (notes.isEmpty) {
              return Center(
                child: Text(
                  query.trim().isEmpty
                      ? 'Belum ada catatan'
                      : 'Tidak ada catatan yang cocok dengan "$query"',
                ),
              );
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, i) => itemBuilder != null
                  ? itemBuilder!(context, notes[i])
                  : ListTile(title: Text(notes[i].title)),
            );
          },
        );
  }
}
