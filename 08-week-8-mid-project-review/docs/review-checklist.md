# Review Checklist - Week 8

## 1. Audit Riwayat Git (Praktikum 1)

Perintah yang dijalankan: `git log --oneline -15`, `git branch -a`, `git status`.

| Temuan | Bukti | Tindak lanjut |
|---|---|---|
| Commit langsung ke `main` | Seluruh commit Week 7 berada di `main`, belum ada `develop` maupun `feature/*` | Dibuat `develop`, lalu setiap pekerjaan Week 8 memakai branch `feature/*` atau `chore/*` dan masuk lewat Pull Request |
| Satu commit memuat banyak perubahan | `f070e81` memuat refactoring, README, dan screenshot sekaligus | Week 8 memisahkan commit per perubahan logis dengan `git add` per file |
| Pesan commit tidak konsisten | `docs: update README to clarify token persistence...` tanpa scope dan bercampur bahasa | Memakai format `tipe(scope): deskripsi` |
| Pesan commit tidak informatif | `dca847f chore: snapshot before clean architecture` | Pesan menjelaskan apa yang berubah dan di mana |
| File tak terlacak | `git status` bersih, tidak ada | Tidak ada tindakan |
| Branch berumur panjang | Hanya `main`, tidak ada branch lain | Branch fitur dihapus setelah merge |

## 2. Tabel Perbaikan Pesan Commit

| Sebelum | Sesudah | Alasan |
|---|---|---|
| `feat: menyelesaikan Refactoring Challenge Week 7 dan lengkapi README Week 7 serta tambah screenshot bukti verifikasi` | `refactor(notes): selesaikan refactoring challenge clean architecture` | Satu tujuan dan scope jelas. README dan screenshot dipisah ke commit `docs(week7): ...` |
| `chore: snapshot before clean architecture` | `chore(notes): simpan kondisi awal sebelum refactor clean architecture` | Menjelaskan apa yang disimpan dan tujuannya, sehingga mudah dilacak dan di-revert |
| `docs: update README to clarify token persistence and logout behavior` | `docs(auth): jelaskan persistensi token FCM dan perilaku logout` | Menambah scope `auth` dan konsisten berbahasa Indonesia |

## 3. Riwayat Kerja Week 8

| Pekerjaan | Branch | PR | Isi |
|---|---|---|---|
| Validasi judul kosong + test | `feature/notes-validation` | #2 (Closes #1) | `ValidationFailure`, use case `AddNote`, pesan error di dialog, `add_note_test.dart`, fake test dipusatkan di `test/fakes/` |
| Rapikan format project | `chore/dart-format` | #3 (merged) | `dart format` pada 30 file di luar PR #2, tanpa perubahan logika |
| Otomatisasi pemeriksaan | `feature/ci-github-actions` | #4 (merged) | `.github/workflows/ci.yml`: format, analyze, test pada setiap PR |

Alur setiap PR: issue, branch dari `develop`, commit kecil, PR ke `develop`, review, merge.

## 4. Checklist Kesiapan Tengah Semester

| Item | Status | Bukti |
|---|---|---|
| Struktur feature-first terbukti (tiga grep sterilitas Minggu 7) | [x] | README Week 7, Checklist poin 1 sampai 3 |
| `flutter analyze` bersih | [x] | `No issues found!` |
| `dart format` rapi | [x] | PR #3 dan PR #2; CI sempat menolak 3 file yang belum rapi (`screenshots/03-ci-merah-format.png`), lalu diperbaiki |
| `flutter test` hijau | [x] | 12 test lulus |
| CI hijau di PR | [x] | PR #4 berhasil hijau (All checks have passed) setelah perbaikan format dan test |
| Issue dan PR kecil, satu fitur | [~] | Issue #1, PR #2. Ukuran akhir +192 -116 (308 baris), melewati batas 300 sebanyak 8 baris. Lihat catatan di bawah tabel |
| Commit konvensional | [x] | Tabel bagian 2 dan riwayat commit PR #2 |
| Review AI terdokumentasi | [x] | [ai-review-vs-keputusan.md](ai-review-vs-keputusan.md) |
| Review sejawat dan tindak lanjutnya | [x] | Reviewer (Febrianucup) memberikan Request Changes, semua temuan (Kebenaran, Arsitektur, Test) sudah diperbaiki. Reviewer memberikan Approve |
| README Week 8 + screenshot + cara menjalankan | [x] | Dokumen README lengkap dengan screenshot bukti dan instruksi |


Catatan ukuran PR #2: fitur inti (dua commit awal) berukuran +145 -25 (170 baris). Total
akhir 308 baris karena dua tindak lanjut yang ditambahkan selama proses: format 5 file
(`797a585`) dan pemusatan `FakeNoteRepository` (`cd846b3`, `789ea32`), yang sebagian besar
berupa penghapusan kode test duplikat. Format 30 file lainnya sudah dipisah ke PR #3
(+112 -92) agar PR #2 tidak membengkak menjadi sekitar 430 baris. Pelajaran: refactor test
sebaiknya dibuat PR tersendiri sejak awal.

## 5. Definisi Selesai (Mid Review)

| Syarat | Status |
|---|---|
| Aplikasi berjalan identik dengan akhir Minggu 7 | [x] (perilaku lama tidak berubah, hanya validasi judul kosong yang ditambah) |
| Tiga pemeriksaan mesin hijau | [x] Lokal (analyze, format, test) & CI (GitHub Actions hijau) |
| Minimal 1 PR kecil di-merge via review sejawat | [x] PR #2 di-approve dan di-merge ke `develop` |
| README memuat status paruh semester dan peta issue/PR | [x] README dan checklist ini sudah dilengkapi |