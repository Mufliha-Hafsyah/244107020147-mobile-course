# LAPORAN PRAKTIKUM - WEEK 3 PEMROGRAMAN MOBILE

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## JOBSHEET WEEK 3 Navigation & State Management

---
### Praktikum 1 — Aplikasi Multi-page dengan GoRouter
![Flutter Pub](screenshots/praktikum1-flutterpub.png)<br>
![Home](screenshots/praktikum1-home.png)<br>
![Detail](screenshots/praktikum1-detail.png)<br>

**Analisis:**<br>
Saat item ditekan, path berpindah dari `/` ke `/detail/:id` sesuai id item yang dipilih. Tombol back pada sistem secara otomatis mengarahkan kembali ke Home karena GoRouter mengelola stack navigasi berdasarkan struktur `routes` (nested route `detail/:id` di bawah `/`). Dibandingkan Navigator 1.0, pendekatan ini membuat struktur route lebih terorganisir dan mendukung deep link (akses langsung ke path tertentu tanpa harus melewati Home terlebih dahulu).

---