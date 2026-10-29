# LAPORAN PRAKTIKUM - WEEK 8 PEMROGRAMAN MOBILE

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## JOBSHEET WEEK 8 Mid Project Review & Code Review

Minggu ini tidak membuat project baru. Yang direview adalah project Week 7 (`07-week-7-clean-architecture`, lanjutan `week5_offline_notes`). Perubahan kodenya tetap berada di folder Week 7 dan masuk lewat Pull Request, sedangkan folder ini hanya berisi dokumentasi proses (`README.md`, `docs/`, `screenshots/`).<br>

**Alur kerja:** issue, branch dari `develop`, commit kecil, Pull Request ke `develop`, review, merge.

| Branch | Peran |
|---|---|
| `main` | Selalu bisa dirilis, tidak dikerjakan langsung |
| `develop` | Integrasi, target default semua PR (juga dijadikan default branch repository) |
| `feature/*` | Kerja satu fitur, pendek |
| `chore/*`, `docs/*` | Perubahan non-fitur (format, dokumentasi) |

---
### Praktikum 1: Audit Riwayat dan Branch Kerja yang Benar

#### Langkah 1: Audit riwayat

Perintah yang dijalankan di repository portfolio: `git log --oneline -15`, `git branch -a`, dan `git status`.

```
f070e81 (HEAD -> main) feat: menyelesaikan Refactoring Challenge Week 7 dan  lengkapi README Week 7 serta tambah screenshot bukti verifikasi
0692143 docs: tambah dokumentasi AI Challenge dan navigasi README
7582e50 refactor: praktikum 3 - DI terpusat, halaman notes ke presentation, verifikasi dependency rule
6a1bb1c refactor: praktikum 2 - domain dan data layer fitur notes
b5625f5 docs: praktikum 1 - pemetaan file ke layer dan pencarian pelanggaran
dca847f chore: snapshot before clean architecture
772e856 docs: memperbaiki format README agar tabel pengujian ketiga app state terbaca
2052ea2 test: menambahkan unit test sesuai pola modul di auth_push_test.dart
8cfa282 docs: memindahkan detail test ke section Testing, meringkas checklist poin 5
6702609 docs: tambahkan bukti uji reinstall/clear data untuk token FCM
0241e7c docs: Menambahkan mini project dan menjawab refleksi di README
bea5cb8 docs: update README to clarify token persistence and logout behavior
c67bc37 docs: menambahkan checklist verifikasi mandiri
8d5d24b test: unit test routeFromMessage dan TokenStore dengan fake secure storage
5f2b5e4 refactor: konstanta rute dan pindahkan mapping error Dio
```

`git branch -a` hanya menampilkan `main` dan `remotes/origin/main`. `git status` bersih (`nothing to commit, working tree clean`), tetapi branch lokal tertinggal 4 commit dari `origin/main`.

| Temuan | Bukti | Tindak lanjut |
|---|---|---|
| Commit langsung ke `main` | Seluruh commit Week 7 ada di `main`, tidak ada branch lain | Dibuat `develop`; pekerjaan Week 8 memakai branch terpisah dan masuk lewat PR |
| Satu commit memuat banyak perubahan | `f070e81` memuat refactoring, README, dan screenshot sekaligus | Dipisah per perubahan logis dengan `git add` per file |
| Pesan commit tidak konsisten | `docs: update README to clarify token persistence...` tanpa scope dan berbeda bahasa dengan commit lain | Memakai format `tipe(scope): deskripsi` |
| Pesan commit kurang informatif | `dca847f chore: snapshot before clean architecture` | Pesan menjelaskan apa dan di mana yang berubah |
| Branch lokal tertinggal dari remote | `Your branch is behind 'origin/main' by 4 commits` | `git pull` (fast-forward) sebelum membuat branch |
| File tak terlacak | Tidak ada | Tidak ada tindakan |

#### Langkah 2: Branch kerja

Branch `develop` belum ada, jadi dibuat sekali dari `main` (sesuai catatan jobsheet), lalu di-push.

```
git fetch origin
git pull
git checkout -b develop
git push -u origin develop
```

Branch fitur dibuat dari `develop`:

```
git checkout -b feature/notes-validation
```

Bukti: `develop` ada di remote dan branch lokal `feature/notes-validation` melacak `origin/feature/notes-validation`.

#### Langkah 3: Perbaikan pesan commit

| Sebelum | Sesudah | Alasan |
|---|---|---|
| `feat: menyelesaikan Refactoring Challenge Week 7 dan  lengkapi README Week 7 serta tambah screenshot bukti verifikasi` | `refactor(notes): selesaikan refactoring challenge clean architecture` | Satu tujuan dan scope jelas. README dan screenshot dipisah ke commit `docs(week7): ...` |
| `chore: snapshot before clean architecture` | `chore(notes): simpan kondisi awal sebelum refactor clean architecture` | Menjelaskan apa yang disimpan dan tujuannya, sehingga mudah dilacak dan di-revert |
| `docs: update README to clarify token persistence and logout behavior` | `docs(auth): jelaskan persistensi token FCM dan perilaku logout` | Menambah scope `auth` dan konsisten berbahasa Indonesia |

Tabel lengkap beserta riwayat kerja Week 8 ada di [docs/review-checklist.md](docs/review-checklist.md).

---