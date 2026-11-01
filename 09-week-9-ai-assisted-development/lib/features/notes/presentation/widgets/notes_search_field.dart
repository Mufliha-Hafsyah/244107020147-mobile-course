import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_providers.dart';

class NotesSearchField extends ConsumerWidget {
  const NotesSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Cari judul catatan',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (v) => ref.read(notesQueryProvider.notifier).set(v),
    );
  }
}
