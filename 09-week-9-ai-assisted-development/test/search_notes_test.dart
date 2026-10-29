import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/search_notes.dart';

void main() {
  const search = SearchNotes();

  final notes = [
    Note(id: 1, title: 'Belanja', updatedAt: DateTime(2026, 1, 1)),
    Note(id: 2, title: 'Catatan Rapat', updatedAt: DateTime(2026, 1, 2)),
    Note(id: 3, title: 'Ide Proyek', updatedAt: DateTime(2026, 1, 3)),
  ];

  test('query kosong mengembalikan semua catatan', () {
    expect(search(notes, ''), notes);
    expect(search(notes, '   '), notes);
  });

  test('query mencocokkan judul tanpa peduli huruf besar/kecil', () {
    final result = search(notes, 'CATATAN');
    expect(result.map((n) => n.id), [2]);
  });

  test('query parsial mencocokkan lebih dari satu catatan', () {
    final result = search(notes, 'a');
    expect(result.map((n) => n.id), [1, 2]);
  });

  test('query tanpa hasil mengembalikan list kosong', () {
    expect(search(notes, 'zzz'), isEmpty);
  });
}