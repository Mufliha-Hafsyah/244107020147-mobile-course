# LAPORAN PRAKTIKUM - WEEK 5 PEMROGRAMAN MOBILE

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## JOBSHEET WEEK 5 Local Storage & Offline First

---
### Praktikum 1: SharedPreferences

Praktikum ini membangun repository untuk menyimpan preferensi sederhana (mode gelap/terang dan waktu terakhir dibuka aplikasi) menggunakan SharedPreferences, dihubungkan ke Riverpod melalui `AsyncNotifierProvider`.

#### Analisis

Seluruh akses `SharedPreferences.getInstance()` dipusatkan pada `PrefsRepository`, bukan dipanggil langsung dari widget. Hal ini menghindari kesalahan umum yang disebutkan pada modul, yaitu memanggil `SharedPreferences.getInstance()` langsung di dalam `build()` widget, yang akan membuat hasilnya sulit di-cache dan diuji. Pola ini konsisten dengan repository pattern yang telah dipelajari pada Minggu 4, hanya saja sumber datanya berbeda (penyimpanan lokal, bukan REST API).

---
### Praktikum 2: SQLite dan repository catatan


#### Hasil Implementasi

| Kondisi Kosong | Dialog Tambah Catatan | Setelah Tambah Catatan | Setelah Hapus |
|---|---|---|---|
| ![Kosong](screenshots/praktikum2-notes-kosong.png) | ![Dialog](screenshots/praktikum2-notes-dialog-tambah.png) | ![List](screenshots/praktikum2-notes-list.png) | ![Delete](screenshots/praktikum2-notes-delete.png) |

#### Analisis

Badge "Belum sinkron: X" pada `AppBar` terbukti akurat mengikuti jumlah catatan dengan `dirty = true`, bertambah saat catatan baru ditambahkan (karena `addNote` selalu membuat catatan dengan `dirty: true`) dan berkurang saat catatan dihapus. 

---
### Praktikum 3: Cache-first dan antrean sync

#### Hasil Implementasi

| Cache Posts Tetap Muncul Saat Offline | Sebelum Sync | Setelah Sync Berhasil |
|---|---|---|
| ![Offline](screenshots/praktikum3-cache-offline.png) | ![Sebelum](screenshots/praktikum3-sync-sebelum.png) | ![Sync](screenshots/praktikum3-sync-berhasil.png) |

#### Analisis

- Pengujian mode offline membuktikan bahwa data cache tetap dapat diakses sepenuhnya tanpa koneksi internet, karena `cachedPostsProvider` membaca dari tabel `cached_posts` di SQLite, bukan langsung dari jaringan. Kegagalan `_refreshInBackground()` saat offline ditangani secara diam-diam (`catch (_) {}`) agar tidak mengganggu data cache yang sudah valid ditampilkan ke pengguna.
- Tombol sinkronisasi pada `NotesPage` memanggil `syncNotes()` yang membaca `countDirty()` terlebih dahulu, lalu menandai seluruh catatan sebagai bersih (`dirty = 0`) setelah simulasi pengiriman ke server berhasil. Invalidasi pada `notesProvider` dan `dirtyCountProvider` setelah sinkronisasi memastikan badge dan label "Belum tersinkron" pada tiap catatan langsung diperbarui tanpa perlu me-restart aplikasi.

---
### AI Prompt Challenge

Dokumentasi lengkap proses AI Prompt Challenge (prompt yang digunakan, output awal AI, temuan masalah, dan proses perbaikan) dapat dilihat di:

[docs/ai-verification.md](docs/ai-verification.md)

---