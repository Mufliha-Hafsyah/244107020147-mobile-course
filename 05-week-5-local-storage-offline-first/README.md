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