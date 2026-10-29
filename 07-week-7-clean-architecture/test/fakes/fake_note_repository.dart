import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';

/// Repository palsu bersama untuk semua test.
/// [items] dikembalikan oleh fetchNotes, [fail] membuat fetchNotes dan
/// addNote mengembalikan LocalFailure.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  int addCalls = 0;
  String? lastTitle;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    lastTitle = title;
    if (fail) {
      return (note: null, failure: const LocalFailure('db locked (simulasi)'));
    }
    return (
      note: Note(title: title, updatedAt: DateTime(2026, 10, 29)),
      failure: null,
    );
  }

  @override
  Future<Failure?> deleteNote(int id) => throw UnimplementedError();

  @override
  Future<({int count, Failure? failure})> countDirty() =>
      throw UnimplementedError();

  @override
  Future<Failure?> markAllSynced() => throw UnimplementedError();
}
