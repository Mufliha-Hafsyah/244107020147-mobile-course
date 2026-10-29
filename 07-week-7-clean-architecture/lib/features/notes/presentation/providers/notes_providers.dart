import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';
import '../../domain/usecases/add_note.dart';

// Data layer: database opener disuntikkan (mudah diganti fake saat test)
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima abstraksi, bukan implementasi
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

// Presentation layer: state untuk UI
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw FailureException(result.failure!);
    return result.notes;
  }

  // CRUD satu baris: langsung ke repository, tanpa use case.
  Future<String?> addNote(String title) async {
    final result = await ref.read(addNoteProvider).call(title: title);
    final failure = result.failure;
    
    if (failure != null) return failure.message;
    
    ref.invalidateSelf();
    return null;
  }

  Future<void> deleteNote(int id) async {
    final failure = await ref.read(noteRepositoryProvider).deleteNote(id);
    if (failure != null) {
      state = AsyncError(FailureException(failure), StackTrace.current);
      return;
    }
    ref.invalidateSelf();
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider); // rebuild otomatis saat notes berubah
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  if (result.failure != null) throw FailureException(result.failure!);
  return result.count;
});
