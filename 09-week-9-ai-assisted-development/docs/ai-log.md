# AI Log - Week 9 (Fitur Pencarian Catatan)

## 1. Alat AI

| Item | Isi |
|---|---|
| Branch | `feature/notes-search` |
| Asisten AI | Claude (Anthropic), lewat chat claude.ai |
| Fitur yang dikerjakan | Pencarian judul catatan + empty state, pada project `07-week-7-clean-architecture` |
| Branch | `feature/notes-search` |

## 2. Prompt (5 slot + konteks yang ditempel)

```
Peran: senior Flutter dev.
Konteks: project Flutter feature-first Clean Architecture
(presentation -> domain <- data), state Riverpod
(flutter_riverpod <VERSI DARI pubspec.lock>), SQLite + Dio.
NotesPage membaca notesProvider (<TIPE NOTIFIER YANG SUDAH KAMU CEK>)
dan menampilkan ListView. Kegagalan dibungkus Failure di
core/failures.dart.
Tugas: tambah pencarian judul catatan (abaikan huruf besar/kecil)
+ empty state saat tidak ada yang cocok.
Batas: jangan ubah arsitektur; jangan panggil SQLite dari widget;
logika filter harus di use case domain yang murni
(lib/features/notes/domain/usecases/search_notes.dart, class
SearchNotes, tanpa import Flutter/Dio/SQLite); jangan ubah
repository dan data layer.
Output: kode lengkap + 1 unit test sukses + 1 unit test query tak
cocok + 1 widget test untuk empty state + cara uji manual.
```

Konteks kode yang ditempel (entity, tanpa secret):

```dart
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
```

Yang sengaja tidak disertakan: token, API key, dan isi seluruh repo.

## 3. Output awal AI

**`lib/features/notes/domain/usecases/search_notes.dart`**
```dart
import '../entities/note.dart';

class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return notes;
    return notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }
}
```

**Tambahan di `lib/features/notes/presentation/providers/notes_providers.dart`**

Tambahkan import `'../../domain/usecases/search_notes.dart'`, lalu tambahkan kode ini di bagian bawah file:
```dart
final searchNotesProvider = Provider<SearchNotes>((ref) => const SearchNotes());

class NotesQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final notesQueryProvider =
    NotifierProvider<NotesQueryNotifier, String>(NotesQueryNotifier.new);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(notesQueryProvider);
  final search = ref.watch(searchNotesProvider);
  return ref.watch(notesProvider).whenData((notes) => search(notes, query));
});
```

**`lib/features/notes/presentation/widgets/notes_search_field.dart`**
```dart
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
```

**`lib/features/notes/presentation/widgets/notes_result_list.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesResultList extends ConsumerWidget {
  const NotesResultList({super.key, this.itemBuilder});

  final Widget Function(BuildContext context, Note note)? itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(notesQueryProvider);
    return ref.watch(filteredNotesProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('Terjadi kesalahan')),
          data: (notes) {
            if (notes.isEmpty) {
              return Center(
                child: Text(query.trim().isEmpty
                    ? 'Belum ada catatan'
                    : 'Tidak ada catatan yang cocok dengan "$query"'),
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
```

**Cara memasang di halaman:** di `notes_page.dart`, taruh `NotesSearchField()` di atas daftar, dan ganti `ListView` lama dengan `NotesResultList(itemBuilder: (context, note) => NoteTile(...))` memakai tile yang sudah ada. Detail ini baru bisa dipastikan setelah aku melihat file halamannya.

**`test/search_notes_test.dart`**
```dart
import 'package:flutter_test/flutter_test.dart';
// sesuaikan <nama_package> dengan name: di pubspec.yaml
import 'package:<nama_package>/features/notes/domain/entities/note.dart';
import 'package:<nama_package>/features/notes/domain/usecases/search_notes.dart';

void main() {
  final notes = [
    Note(title: 'Belanja', updatedAt: DateTime(2026)),
    Note(title: 'BELANJA bulanan', updatedAt: DateTime(2026)),
    Note(title: 'Kuliah', updatedAt: DateTime(2026)),
  ];
  const search = SearchNotes();

  test('query cocok: abaikan huruf besar/kecil', () {
    expect(search(notes, 'belanja'), hasLength(2));
  });

  test('query tak cocok mengembalikan kosong', () {
    expect(search(notes, 'zzz-tak-ada'), isEmpty);
  });
}
```

**`test/notes_empty_state_test.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:<nama_package>/features/notes/domain/entities/note.dart';
import 'package:<nama_package>/features/notes/presentation/providers/notes_providers.dart';
import 'package:<nama_package>/features/notes/presentation/widgets/notes_result_list.dart';
import 'package:<nama_package>/features/notes/presentation/widgets/notes_search_field.dart';

class _FakeNotes extends NotesNotifier {
  @override
  Future<List<Note>> build() async =>
      [Note(title: 'Belanja', updatedAt: DateTime(2026))];
}

void main() {
  testWidgets('menampilkan empty state saat tidak ada yang cocok',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [notesProvider.overrideWith(_FakeNotes.new)],
      child: const MaterialApp(
        home: Scaffold(
          body: Column(children: [
            NotesSearchField(),
            Expanded(child: NotesResultList()),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Belanja'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('Tidak ada catatan yang cocok'), findsOneWidget);
  });
}
```

**Cara uji manual:** jalankan `flutter run`, lalu coba 3 query: (1) kosong, semua catatan tampil; (2) judul yang ada, dengan huruf besar/kecil berbeda; (3) `zzz-tak-ada`, muncul teks empty state.

## 4. Verifikasi

(Diisi setelah kode dibaca, dicek, dan diuji.)

## 5. Tabel terima / tolak

(Diisi setelah verifikasi.)

## 6. Bukti mesin hijau

(Diisi setelah `flutter analyze` dan `flutter test`.)