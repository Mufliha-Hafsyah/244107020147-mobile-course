import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';
import 'fakes/fake_note_repository.dart';
import 'package:week5_offline_notes/core/failures.dart';

void main() {
  group('NotesNotifier Test', () {
    test('addNote mengembalikan pesan error dan TIDAK mengubah state daftar', () async {
      // Kita isi 'items' dengan satu data palsu agar saat build() pertama,
      // fetchNotes BERHASIL (state tidak error dari awal).
      // Lalu kita set 'fail: true' agar addNote GAGAL.
      // Tapi FakeNoteRepository-mu membuat fail ini berlaku untuk keduanya.
      // Jadi kita buat trik: pakai subclass kecil di bawah.
      final fakeRepo = _FakeAddFailRepository();
      
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      // Tunggu build() awal selesai
      await container.read(notesProvider.future);

      // Panggil addNote (harusnya gagal)
      final error = await container.read(notesProvider.notifier).addNote('Judul Valid');

      // Assert: pesan error dikembalikan
      expect(error, isNotNull);
      expect(error, 'db locked (simulasi)');
      
      // Assert: state daftar TETAP berisi data, tidak menjadi error
      final state = container.read(notesProvider);
      expect(state.hasError, isFalse);
      expect(state.value, isNotNull);
    });
  });

  group('NotesPage Widget Test', () {
    testWidgets('dialog tetap terbuka dan menampilkan error saat judul kosong', (tester) async {
      final fakeRepo = FakeNoteRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Buka dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tekan Tambah tanpa mengisi apa pun
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      // Assert: pesan error muncul
      expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
      
      // Assert: Dialog masih ada (tidak tertutup)
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}

/// Subclass khusus test: fetchNotes BERHASIL, addNote GAGAL.
class _FakeAddFailRepository extends FakeNoteRepository {
  _FakeAddFailRepository() : super(items: const <Note>[]);

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: const <Note>[], failure: null);
  }

  // TAMBAHKAN INI: Paksa addNote untuk selalu gagal
  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    return (
      note: null, 
      failure: const LocalFailure('db locked (simulasi)')
    );
  }
}