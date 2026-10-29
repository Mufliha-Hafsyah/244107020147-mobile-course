# Review AI vs Keputusan Final (Week 8)

Dokumen ini mencatat hasil review awal oleh AI pada PR #2 dan keputusan final saya
atas setiap temuan, sesuai AI Verification Checklist Jobsheet 8.

## 1. Konteks

| Item | Isi |
|---|---|
| PR yang direview | PR #2 `feat(notes): validasi judul kosong + test` (branch `feature/notes-validation` ke `develop`) |
| Issue terkait | #1 Validasi judul catatan kosong harus memberi pesan error |
| Reviewer AI | Claude (Anthropic), lewat percakapan chat |
| Tanggal review | 29 Oktober 2026 |
| Cara memberi konteks | Isi file yang relevan (use case, repository, provider, halaman notes, test) saya tempelkan ke percakapan. AI tidak menjalankan kode apa pun. |
| Catatan | Review AI adalah review awal. Review sejawat oleh teman dicatat terpisah (bagian 5). |

## 2. Prompt dan output awal AI

Prompt: saya meminta AI bertindak sebagai reviewer PR #2 (kebenaran, arsitektur,
test, keterbacaan) pada project Flutter Clean Architecture (Riverpod, GoRouter,
SQLite).

Output awal AI (ringkas):

| # | Kategori | Level | Temuan AI |
|---|---|---|---|
| 1 | Kebenaran | Blocker | Kode belum lolos `dart format` (indentasi `notes_page.dart` tampak tidak rapi) |
| 2 | Kebenaran | Saran | Tombol Tambah tidak dinonaktifkan saat `await addNote`, tap ganda bisa menyimpan catatan ganda |
| 3 | Kebenaran | Saran | `TextEditingController` di `_showAddDialog` tidak di-`dispose` |
| 4 | Arsitektur | Saran | `deleteNote` di `NotesNotifier` masih memanggil repository langsung, tidak lewat use case seperti `addNote` |
| 5 | Test | Saran | Tidak ada widget test untuk perilaku dialog (tetap terbuka + pesan muncul) |
| 6 | Keterbacaan | Saran | `FakeNoteRepository` terduplikasi di file-file test |

Keputusan reviewer AI: Request changes (karena temuan #1).

## 3. Verifikasi temuan (bukti)

| # | Apakah temuan benar-benar ada? | Bukti |
|---|---|---|
| 1 | **Terbukti benar** | `dart format lib test` mengubah 35 dari 35 file. `git diff --stat` menunjukkan `notes_page.dart` berubah 44 baris. CI GitHub Actions gagal di langkah format: `Formatted 33 files (3 changed)` pada `failures.dart`, `notes_page.dart`, `notes_providers.dart` (screenshot `screenshots/03-ci-merah-format.png`) |
| 2 | Belum diuji | Belum direproduksi secara manual |
| 3 | Terbukti dari kode | `controller` dibuat di `_showAddDialog` dan tidak pernah di-dispose |
| 4 | **Terbukti benar** | `deleteNote` di `notes_providers.dart` memanggil `ref.read(noteRepositoryProvider).deleteNote(id)` langsung |
| 5 | Terbukti | Folder `test/` hanya berisi test use case, model, format, dan widget_test bawaan, tidak ada test dialog tambah catatan |
| 6 | **Terbukti benar** | Sebelum: `findstr /n "class FakeNoteRepository" test\*.dart` menemukan definisi di `add_note_test.dart:7`, `get_notes_test.dart:7`, dan `_FakeNoteRepository` di `note_test.dart:9`. Sesudah: `findstr /n "class .*FakeNoteRepository" test\*.dart test\fakes\*.dart` hanya menemukan `test\fakes\fake_note_repository.dart:8` |

Cek dependency rule: tidak ada usulan AI yang mengimpor Flutter/Dio/SQLite ke
domain. Temuan #1 pada dasarnya urusan formatter, bukan arsitektur, sehingga
sebaiknya ditangani otomatis oleh CI (lihat keputusan di bawah).

## 4. Keputusan final

| # | Keputusan | Alasan teknis |
|---|---|---|
| 1 | **Diterima, diterapkan** | Aturan format harus dijaga mesin, bukan reviewer. Dirapikan di PR #2 (commit `797a585`) untuk file yang disentuh PR, sisanya di PR #3 (30 file, dipisah agar PR #2 tetap di bawah 300 baris). CI `ci.yml` ditambahkan agar PR yang tidak rapi ditolak otomatis |
| 2 | Ditunda | Risikonya nyata tetapi dampaknya kecil pada aplikasi catatan lokal. Belum direproduksi, jadi tidak diterapkan tanpa bukti |
| 3 | Ditunda | Kebocoran kecil dan hanya sementara. Perbaikan yang tepat adalah memindahkan dialog ke widget sendiri, yang membuat PR ini membesar |
| 6 | **Diterima, diterapkan** | Fake yang sama di tiga file membuat perubahan interface `NoteRepository` harus diedit di banyak tempat. Fake dipusatkan di `test/fakes/fake_note_repository.dart` (commit `cd846b3` dan `789ea32`). Setelah perubahan: `flutter analyze` bersih dan 11 test lulus |
| 5 | Ditunda | Widget test dialog butuh setup provider override yang cukup besar. Perilaku sudah dibuktikan lewat uji manual dan screenshot, dan aturan validasinya sudah dicakup unit test `add_note_test.dart` |
| 6 | **Diterima, diterapkan** | Fake yang sama di tiga file membuat perubahan interface `NoteRepository` harus diedit di banyak tempat. Fake dipusatkan di `test/fakes/` |

Ringkasan: dari 6 temuan AI, 3 terbukti dan diterima atau ditolak dengan bukti (#1, #4, #6),
3 ditunda dengan alasan tertulis (#2, #3, #5).

## 5. Review sejawat

(Diisi setelah reviewer sejawat selesai: nama reviewer, link review, keputusan Approve/Request changes,
dan tindak lanjut saya atas komentarnya.)

