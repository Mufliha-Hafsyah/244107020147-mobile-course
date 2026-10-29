import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';

import 'fakes/fake_note_repository.dart';

void main() {
  group('NotesNotifier Test', () {
    test('addNote mengembalikan pesan error dan TIDAK mengubah state daftar', () async {
      final fakeRepo = _FakeAddFailRepository();
      
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notesProvider.future);

      final error = await container.read(notesProvider.notifier).addNote('Judul Valid');

      expect(error, isNotNull);
      expect(error, 'db locked (simulasi)');
      
      final state = container.read(notesProvider);
      expect(state.hasError, isFalse);
      expect(state.value, isNotNull);
    });
  });

  group('NotesPage Widget Test', () {
    testWidgets('dialog tetap terbuka dan menampilkan error saat judul kosong', (tester) async {
      // 1. ATUR UKURAN LAYAR TEST AGAR TOMBOL MUNCUL
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Ketik judul kosong (sudah otomatis kosong)
      // Lalu tekan Tambah
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
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