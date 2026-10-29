import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/add_note.dart';
import 'fakes/fake_note_repository.dart';

void main() {
  late FakeNoteRepository repository;
  late AddNote usecase;

  setUp(() {
    repository = FakeNoteRepository();
    usecase = AddNote(repository);
  });

  test('judul kosong menghasilkan ValidationFailure', () async {
    final result = await usecase(title: '');
    
    expect(result.failure, isNotNull);
    expect(result.failure!.message, 'Judul catatan tidak boleh kosong.');
  });

  test('judul berisi whitespace saja ditolak', () async {
    final whitespaces = [' ', '\t', '\n'];
    
    for (final ws in whitespaces) {
      final result = await usecase(title: ws);
      
      expect(result.failure, isNotNull, reason: 'Harus gagal untuk whitespace: "$ws"');
      expect(result.failure!.message, 'Judul catatan tidak boleh kosong.');
    }
  });

  test('judul valid berhasil disimpan', () async {
    final result = await usecase(title: 'Catatan Penting');
    
    expect(result.failure, isNull);
    // Perhatikan: fake repository menggunakan 'items', bukan 'notes'
    expect(repository.addCalls, 1); 
    expect(repository.lastTitle, 'Catatan Penting');
  });
}