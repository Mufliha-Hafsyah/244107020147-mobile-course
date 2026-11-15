## AI Challenge

### Catatan Pengerjaan

Dokumentasi AI Challenge disusun setelah refactor selesai. Output AI di bawah dihasilkan dengan instruksi menjawab dari kondisi sebelum refactor (commit snapshot `dca847f`), lalu dinilai terhadap keputusan akhir yang sudah diterapkan. 

---
### AI Prompt Challenge
**Prompt yang Digunakan**

```
Project Flutter saya: week5_offline_notes (catatan offline dengan SQLite,
sinkronisasi, cache posts dari API, dan pengaturan mode gelap).
Kondisi kini, struktur lib/ sebelum refactor:

lib/data/local/cached_post.dart
lib/data/local/db.dart
lib/data/local/note.dart
lib/data/prefs.dart
lib/data/repositories/note_repository.dart
lib/data/sync.dart
lib/main.dart
lib/pages/main_shell.dart
lib/pages/note_detail_page.dart
lib/pages/notes_page.dart
lib/pages/posts_cache_page.dart
lib/pages/settings_page.dart
lib/pages/widgets/note_tile.dart
lib/router.dart

Masalah yang saya lihat: repository tercampur antara akses SQLite, Dio,
dan cache posts dalam satu kelas; notifier memanggil repository
konkret; pesan error menyertakan exception mentah.

Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes, posts (cache-first),
   dan settings (mode gelap via SharedPreferences).
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

AI yang digunakan: Claude (chat assistant).

---
### Output Awal AI

#### 1. Struktur target (feature-first)

```
lib/
├── main.dart
├── router.dart
├── core/
│   └── failures.dart
├── data/                      # sumber data bersama (tetap)
│   ├── prefs.dart
│   └── local/db.dart
├── pages/main_shell.dart      # kerangka navigasi lintas fitur (tetap)
└── features/
    ├── notes/
    │   ├── domain/
    │   │   ├── entities/note.dart
    │   │   ├── repositories/note_repository.dart   # interface
    │   │   └── usecases/{get_notes,sync_notes}.dart
    │   ├── data/
    │   │   ├── models/note_model.dart
    │   │   └── repositories/note_repository_impl.dart
    │   └── presentation/{providers,pages,widgets}/
    ├── posts/
    │   ├── domain/{entities/post.dart,repositories/post_repository.dart}
    │   ├── data/{models/post_model.dart,repositories/post_repository_impl.dart}
    │   └── presentation/{providers,pages}/
    └── settings/
        ├── domain/{entities,repositories}/
        ├── data/repositories/settings_repository_impl.dart
        └── presentation/{providers,pages}/
```

Aturan dependensi: presentation -> domain <- data. `domain` hanya mengimpor sesama domain dan `core`.

#### 2. Pemetaan file lama

| File lama | Tujuan baru |
|---|---|
| `data/repositories/note_repository.dart` | **Pecah:** bagian notes -> `NoteRepositoryImpl`, bagian cache posts + Dio -> `PostRepositoryImpl`. File lama dihapus. |
| `data/local/note.dart` | **Pecah:** entity `Note` (domain) + `NoteModel` (data, berisi toMap/fromMap). Hapus. |
| `data/local/cached_post.dart` | Tampak tidak dipakai. Pastikan dengan grep, lalu **hapus**; diganti `Post` + `PostModel`. |
| `data/local/db.dart` | **Tetap**, jadi sumber data bersama notes dan posts. |
| `data/prefs.dart` | **Tetap**, dibungkus `SettingsRepositoryImpl`. Periksa `markOpenedNow`/`getLastOpened`; bila tidak dipakai, kandidat hapus. |
| `data/sync.dart` | **Hapus.** Logika cache-first pindah ke `posts_providers.dart`, akses data ke `PostRepositoryImpl`. |
| `pages/settings_page.dart` | **Pindah** ke `features/settings/presentation/pages/`; provider dipisah ke `providers/`. `main.dart` bergantung pada `darkModeProvider` yang tadinya tertanam di file halaman; setelah dipisah, `main.dart` cukup mengimpor provider-nya. |
| `pages/posts_cache_page.dart` | **Pindah** ke `features/posts/presentation/pages/`. |
| `pages/notes_page.dart` | **Pecah:** `NotesNotifier`, `notesProvider`, `dirtyCountProvider`, dan `noteRepositoryProvider` -> `features/notes/presentation/providers/`; widget halamannya -> `features/notes/presentation/pages/`. Logika sinkron yang tertanam di `onPressed` tombol sync -> use case `SyncNotes`. |
| `pages/note_detail_page.dart` | **Pindah** ke `features/notes/presentation/pages/`. |
| `pages/widgets/note_tile.dart` | **Pindah** ke `features/notes/presentation/widgets/`. |
| `pages/main_shell.dart` | **Tetap** (lintas fitur). |
| `router.dart`, `main.dart` | **Tetap**, update import. |

#### 3. Over-engineering vs perlu

- **Use case: hanya bila ada aturan atau menggabungkan operasi.**
  - `SyncNotes`: perlu (menggabungkan hitung dirty, tandai tersinkron, aturan sinkron).
  - `GetNotes`: pembungkus tipis. Boleh dilewati, dipertahankan hanya agar ada satu contoh use case yang jelas.
  - Add/delete catatan: **jangan** dibuatkan use case; notifier langsung ke repository.
  - Posts: **tanpa use case**, hanya meneruskan panggilan.
  - Settings: baca langsung lewat repository; use case `ToggleDarkMode` opsional (menggabungkan baca + simpan + balik nilai).
- **Entity `AppSettings` untuk satu boolean: over-engineering.** Cukup `bool`. Layak hanya bila jobsheet mewajibkan pola lengkap.
- **Entity `Post` vs `Map<String, dynamic>`: layak.** Menghilangkan `post['title'] as String?` dan casting di UI.
- **Interface repository untuk posts dan settings: layak**, biayanya kecil dan membuat keduanya bisa diuji dengan fake.
- **Pesan error:** pisahkan `message` (untuk UI) dan `cause` (untuk debugging) di `Failure`, agar `$e` tidak sampai ke layar.

#### 4. Wiring DI dengan Riverpod

Semua pembuatan objek konkret hanya di `presentation/providers`:

```dart
// features/notes/presentation/providers/notes_providers.dart
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(openDb: openNotesDb),
);

final syncNotesProvider = Provider<SyncNotes>(
  (ref) => SyncNotes(ref.watch(noteRepositoryProvider)),
);

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

// features/posts/presentation/providers/posts_providers.dart
final postRepositoryProvider =
    Provider<PostRepository>((ref) => PostRepositoryImpl());

// features/settings/presentation/providers/settings_providers.dart
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(prefs: PrefsRepository()),
);
```

Widget hanya memakai `ref.watch(...)`, tidak pernah `Repository()`. Test cukup meng-override provider dengan fake.

#### 5. Trade-off keputusan

| Keputusan | Alasan | Biaya |
|---|---|---|
| Feature-first, bukan layer-first | Tiga fitur terpisah; satu fitur bisa dipahami atau dihapus sendiri | Lebih banyak folder untuk fitur kecil |
| `data/db.dart` dan `prefs.dart` tetap di tempat | Dipakai lintas fitur, mengurangi perpindahan file | Folder `data/` global tersisa, kurang murni |
| Record `({data, failure})`, bukan `Either` | Tanpa package tambahan, cukup untuk kebutuhan ini | Kurang ekspresif dibanding fpdart |
| Use case selektif | Menghindari boilerplate untuk CRUD | Konvensi tidak seragam antarfitur, perlu dijelaskan |
| DI hanya dengan Riverpod | Tidak menambah dependensi | Wiring tersebar di provider tiap fitur |

#### 6. Urutan migrasi

1. Commit snapshot.
2. Buat `core/failures.dart` (`Failure` dengan `message` + `cause`).
3. Pecah fitur notes, lalu posts, lalu settings, satu fitur per commit.
4. Setelah tiap fitur: `flutter analyze` + `flutter test` + cek manual.
5. Hapus file lama hanya setelah grep memastikan tidak ada pemakai.

---
### Verifikasi Menggunakan AI Verification Checklist

| Poin Checklist | Hasil Verifikasi |
|---|---|
| Interface repository di `domain`, implementasi di `data`? | **Lulus.** Usulan AI menaruh interface di `domain/repositories/` dan implementasi di `data/repositories/*_impl.dart`. Pada hasil akhir, struktur ini terbukti ada di ketiga fitur (`notes`, `posts`, `settings`). |
| `domain` bebas import Flutter/Dio/SQLite/Firebase? | **Lulus.** Usulan AI menyebut aturan ini, tetapi klaim itu diperiksa dengan grep pada kode hasil akhir, bukan dengan membaca sekilas. Grep nomor 2 nol hasil, dan grep nomor 4 menunjukkan seluruh import di `domain` hanya mengarah ke `core/failures.dart` dan sesama file domain. |
| Use case dibuat untuk tiap CRUD satu baris? | **Lulus (tidak over-engineering).** AI secara eksplisit tidak membuatkan use case untuk add/delete notes maupun fitur `posts`. Use case hanya muncul di `GetNotes`, `SyncNotes`, dan `ToggleDarkMode`. |
| Entity bebas mapping (`toMap/fromMap/toJson`)? | **Lulus.** Usulan AI memisahkan `Note` (entity) dari `NoteModel` (mapping). Pada hasil akhir, grep nomor 6 nol hasil di seluruh folder `domain`; mapping hanya ada di `data/models`. |
| Wiring DI terpusat di provider, widget tidak membuat repository sendiri? | **Lulus.** Usulan AI memusatkan pembuatan objek konkret di `presentation/providers`. Grep nomor 3 (`lib/pages`) dan nomor 7 (`presentation/pages` dan `presentation/widgets`) sama-sama nol hasil. |
| Keputusan final dan alasan teknis? | **Ada.** Lihat tabel usulan vs keputusan akhir di bawah. Ada tiga titik yang berbeda dari usulan AI. |

**Ringkasan:** keenam poin lulus. Kelemahan usulan AI bukan di poin checklist, melainkan di perilaku kode lama yang tidak dibahasnya (lihat "Temuan di Luar Usulan AI").

---
### Verifikasi Dependency Rule dengan grep

#### Sebelum refactor (commit `dca847f`)

```powershell
git grep -n -E "Dio\(|openDatabase|SharedPreferences\.getInstance|jsonDecode|Repository\(" dca847f -- lib/pages lib/main.dart
```

```
dca847f:lib/pages/notes_page.dart:9:final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());
dca847f:lib/pages/settings_page.dart:5:final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
```

- Dua temuan, keduanya **DI bocor**: file halaman membuat repository konkret sendiri dan menanam provider di file widget.
- Tidak ada pemanggilan `Dio`, `openDatabase`, `SharedPreferences.getInstance`, atau `jsonDecode` langsung di `lib/pages` dan `main.dart`.
- Pelanggaran lain yang tidak tertangkap grep ini: `NoteRepository` lama (`lib/data/repositories/note_repository.dart`) mencampur akses SQLite, cache posts, dan Dio dalam satu kelas tanpa interface, dan `main.dart` bergantung pada `darkModeProvider` yang tertanam di file halaman.

#### Sesudah refactor

**1. Presentation steril dari data mentah**<br>

```powershell
Get-ChildItem lib\features\*\presentation, lib\pages -Recurse -Filter *.dart | Select-String -Pattern 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode'
```

```
(tidak ada hasil)
```

<br>

**2. Domain steril dari framework dan package**<br>

```powershell
Get-ChildItem lib\features\*\domain, lib\core -Recurse -Filter *.dart | Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
```

```
(tidak ada hasil)
```

<br>

**3. Instansiasi manual di pages**<br>

```powershell
Get-ChildItem lib\pages -Recurse -Filter *.dart | Select-String -Pattern 'Repository\(|Dio\(BaseOptions'
```

```
(tidak ada hasil)
```

<br>

**4. Seluruh import di folder domain**<br>

```powershell
Get-ChildItem lib\features\*\domain -Recurse -Filter *.dart | Select-String "^import"
```

```
lib\features\notes\domain\repositories\note_repository.dart:1:import '../../../../core/failures.dart';
lib\features\notes\domain\repositories\note_repository.dart:2:import '../entities/note.dart';
lib\features\notes\domain\usecases\get_notes.dart:1:import '../../../../core/failures.dart';
lib\features\notes\domain\usecases\get_notes.dart:2:import '../entities/note.dart';
lib\features\notes\domain\usecases\get_notes.dart:3:import '../repositories/note_repository.dart';
lib\features\notes\domain\usecases\sync_notes.dart:1:import '../../../../core/failures.dart';
lib\features\notes\domain\usecases\sync_notes.dart:2:import '../repositories/note_repository.dart';
lib\features\posts\domain\repositories\post_repository.dart:1:import '../../../../core/failures.dart';
lib\features\posts\domain\repositories\post_repository.dart:2:import '../entities/post.dart';
lib\features\settings\domain\repositories\settings_repository.dart:1:import '../../../../core/failures.dart';
lib\features\settings\domain\repositories\settings_repository.dart:2:import '../entities/app_settings.dart';
lib\features\settings\domain\usecases\toggle_dark_mode.dart:1:import '../../../../core/failures.dart';
lib\features\settings\domain\usecases\toggle_dark_mode.dart:2:import '../repositories/settings_repository.dart';
```

<br>

Semua import di domain hanya mengarah ke `core/failures.dart` dan sesama file domain; tidak ada import `data` atau `presentation`. File entity (`note.dart`, `post.dart`, `app_settings.dart`) tidak muncul karena tidak punya import sama sekali.
<br>

**5. Static analysis dan test**<br>

```powershell
flutter analyze
flutter test
```

```
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 7.5s)
00:03 +7: All tests passed!
```

<br>

**6. Entity bebas mapping**<br>

```powershell
Get-ChildItem lib\features\*\domain -Recurse -Filter *.dart | Select-String -Pattern 'toMap|fromMap|toJson|fromJson'
```

```
(tidak ada hasil)
```

<br>

**7. Halaman dan widget fitur tidak membuat repository sendiri**<br>

```powershell
Get-ChildItem lib\features\*\presentation\pages, lib\features\*\presentation\widgets -Recurse -Filter *.dart | Select-String -Pattern 'Repository\(|RepositoryImpl\('
```

```
(tidak ada hasil)
```

<br>

Catatan: wiring DI (misalnya `PrefsRepository()` di `settings_providers.dart`) berada di `presentation/providers`. Itu tempat yang dibenarkan jobsheet untuk wiring, sehingga grep nomor 3 hanya mencakup `lib/pages` dan grep nomor 7 hanya mencakup `pages` dan `widgets`.

---
### Perbandingan dengan Keputusan Akhir

#### Arah dependensi

```
presentation (pages, widgets, providers + DI)
      |
      v  bergantung ke
domain (entity, repository interface, use case)  <-- core/failures.dart
      ^
      |  diimplementasikan oleh
data (model, repository impl, db.dart, prefs.dart, Dio)
```

#### Usulan AI vs keputusan akhir

| Topik | Usulan AI | Keputusan akhir | Alasan |
|---|---|---|---|
| Struktur feature-first, `db.dart` dan `prefs.dart` tetap di `lib/data`, `Failure` dengan `message` + `cause`, record sebagai pembungkus hasil, DI Riverpod, hapus `cached_post.dart` | Seperti disebut | Sama | Tiga fitur terpisah; tanpa package tambahan; `prefs.dart` tidak diubah agar key `dark_mode` tetap sama; grep membuktikan `cached_post.dart` tidak dipakai |
| Use case `SyncNotes` dan `GetNotes` | `SyncNotes` perlu; `GetNotes` pembungkus tipis | Keduanya dipertahankan | `GetNotes` dipertahankan sebagai contoh use case yang jelas, dengan sadar nilainya kecil |
| Add/delete notes dan fitur `posts` | Tanpa use case | Sama | CRUD satu baris tanpa aturan bisnis; use case hanya meneruskan panggilan |
| `ToggleDarkMode` | Opsional | Dibuat | Menggabungkan baca, balik nilai, dan simpan |
| Entity `AppSettings` | Over-engineering, cukup `bool` | Tetap dibuat | **Berbeda dari usulan AI.** Jobsheet mewajibkan pola lengkap di fitur kedua |
| `markOpenedNow`, `getLastOpened` | Kandidat hapus | Tidak dihapus, dicatat sebagai temuan | **Berbeda dari usulan AI.** Kode mati bawaan, di luar lingkup tiga poin challenge |

#### Temuan di Luar Usulan AI

Di kode lama, `_refreshInBackground` pada `data/sync.dart` memanggil `ref.invalidateSelf()`, yang memicu `build()` dan refresh lagi secara berulang selama ada internet. Usulan AI tidak menyebut masalah ini; ia baru ketahuan saat fitur `posts` benar-benar dipindahkan. Versi baru mengisi `state` langsung sehingga refresh hanya sekali per pembukaan halaman. Ini satu-satunya perubahan perilaku selama refactor.

---
## Kesimpulan

Usulan struktur dari AI secara keseluruhan akurat: interface di domain, implementasi di data, use case yang dipilih-pilih, dan wiring DI di provider. Poin-poin itu bisa dibuktikan lewat grep pada kode hasil akhir. Namun pembuktian itu hanya mungkin karena dicek dengan perintah, bukan dengan membaca sekilas.<br>

Yang tidak ditangkap AI adalah perilaku di balik kode lama, seperti loop `invalidateSelf()` pada cache posts. Bagian itu baru terlihat saat kodenya benar-benar dipindahkan dan dibaca baris demi baris. Usulan AI juga perlu dinilai ulang pada titik trade-off, misalnya `AppSettings` yang berlebihan secara teknis tetapi tetap dibuat demi pola yang seragam.