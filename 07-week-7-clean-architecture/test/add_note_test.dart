import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/add_note.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.fail = false});

  final bool fail;
  int addCalls = 0;
  String? lastTitle;

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
  Future<({List<Note> notes, Failure? failure})> fetchNotes() =>
      throw UnimplementedError();

  @override
  Future<Failure?> deleteNote(int id) => throw UnimplementedError();

  @override
  Future<({int count, Failure? failure})> countDirty() =>
      throw UnimplementedError();

  @override
  Future<Failure?> markAllSynced() => throw UnimplementedError();
}

void main() {
  test('AddNote menolak judul kosong dan tidak memanggil repository', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '');
    expect(result.note, isNull);
    expect(result.failure, isA<ValidationFailure>());
    expect(result.failure!.message, 'Judul catatan tidak boleh kosong.');
    expect(repo.addCalls, 0);
  });

  test('AddNote menolak judul yang hanya berisi spasi', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.addCalls, 0);
  });

  test('AddNote men-trim judul lalu meneruskannya ke repository', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '  Belanja  ');
    expect(result.failure, isNull);
    expect(result.note!.title, 'Belanja');
    expect(repo.addCalls, 1);
    expect(repo.lastTitle, 'Belanja');
  });

  test('AddNote meneruskan failure dari repository tanpa melempar', () async {
    final repo = FakeNoteRepository(fail: true);
    final result = await AddNote(repo).call(title: 'A');
    expect(result.note, isNull);
    expect(result.failure, isA<LocalFailure>());
  });
}
