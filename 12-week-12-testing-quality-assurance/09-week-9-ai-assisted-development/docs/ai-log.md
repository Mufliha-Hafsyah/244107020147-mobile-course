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

Saya tidak menerima output AI secara mentah. Tiga hal yang saya periksa dan ubah:

1. **Nama package di test:** AI memakai placeholder `package:<nama_package>`. Saya menggantinya dengan `package:week5_offline_notes` sesuai `name:` di `pubspec.yaml`.
2. **Constructor `Note` di test:** AI hanya menulis `Note(title: ..., updatedAt: ...)`. Saya cek file `note.dart` dan memastikan field `id` diisi untuk membedakan hasil filter di test.
3. **Integrasi ke `notes_page.dart`:** AI hanya memberi saran "taruh NotesSearchField di atas daftar". Saya sendiri yang membuka `notes_page.dart`, membungkus body dengan `Column` + `Expanded`, dan menambahkan import `notes_result_list.dart`. Setelah itu ada error `unused_import` untuk `failures.dart` yang saya hapus secara manual.

## 5. Tabel terima / tolak

| Usulan AI | Keputusan | Alasan |
|---|---|---|
| `SearchNotes` di domain, murni tanpa import framework | **Terima** | Sesuai dependency rule Clean Architecture, logika filter tidak butuh SQLite/Flutter |
| `filteredNotesProvider` membaca `notesProvider` dan memfilter via use case | **Terima** | Pemisahan tanggung jawab rapi: UI tidak tahu cara memfilter, cukup *watch* state |
| Widget `NotesSearchField` & `NotesResultList` terpisah | **Terima** | Memudahkan testing (bisa di-pump sendiri) dan menjaga `notes_page.dart` tetap ringkas |
| `NotesResultList` menerima `itemBuilder` opsional | **Terima** | Fleksibel: halaman bisa menyuntikkan `NoteTile` yang sudah ada, termasuk `onTap`/`onDelete` |
| Unit test `search_notes_test.dart` | **Terima, disesuaikan** | Placeholder `nama_package` diganti, konstruktor `Note` disesuaikan dengan field wajib `updatedAt` |
| Widget test `notes_empty_state_test.dart` | **Tolak untuk saat ini** | Widget test butuh *override* `notesProvider` yang cukup rumit; untuk Week 9 fokus ke unit test use case murni. Empty state diverifikasi lewat uji manual. |
| [Review AI] Gunakan `TextEditingController` lokal di search field | **Tolak** | Menambah *boilerplate* (lifecycle dispose). `ref.read` di `onChanged` sudah cukup untuk filter *real-time* |
| [Review AI] Ganti teks statis error di `NotesResultList` dengan `messageFromError` | **Terima** | Selaras dengan arsitektur Week 7. Error handling harus mem-parsing `Failure` agar pesan informatif |
| [Review AI] Cari juga di `body` (isi catatan), bukan hanya judul | **Tolak** | *Out of scope*. Prompt dan jobsheet secara eksplisit hanya meminta pencarian judul |

## 6. Bukti Pengujian Lulus (Analyze & Test)

![Analyze dan Test Hijau](screenshots/flutter-analyze-test.png)<br>

*(Keterangan: +11 test ini mencakup 7 test bawaan Week 7 dan 4 test baru dari `search_notes_test.dart` untuk use case `SearchNotes`).*