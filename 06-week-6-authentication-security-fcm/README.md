# LAPORAN PRAKTIKUM - WEEK 6 PEMROGRAMAN MOBILE

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## JOBSHEET WEEK 6 Authentication, Security & FCM

---
### Praktikum 1: Login, Secure Storage, dan Token Refresh

#### Hasil Implementasi

| Halaman Login | Login Gagal (validasi) | Halaman Home | 
|---|---|---|
| ![Login](screenshots/praktikum1-login.png) | ![Error](screenshots/praktikum1-login-error.png) | ![Home](screenshots/praktikum1-home.gif) |

**Uji persistensi token:**

| Uji | Langkah | Hasil yang Diharapkan | Hasil |
|---|---|---|---|
| Token bertahan | Login berhasil, tutup aplikasi total dari recent apps, buka lagi | Langsung masuk Home tanpa login ulang  | ![Uji persistensi token](screenshots/praktikum1-uji-token-bertahan.gif) |
| Logout menghapus token | Tekan logout, tutup aplikasi total, buka lagi | Tetap di halaman Login | ![Uji persistensi token](screenshots/praktikum1-uji-logout-menghapus-token.gif) |

#### Analisis

- Uji tutup-buka aplikasi membuktikan bahwa `flutter_secure_storage` menyimpan token secara persisten melewati siklus hidup aplikasi, bukan hanya di memori. 
- `AuthNotifier.build()` yang membaca `readAccess()` setiap aplikasi mulai memastikan status login dipulihkan otomatis dari token yang tersimpan, tanpa perlu flag tambahan di tempat lain. 
- Uji logout membuktikan `store.clear()` benar-benar menghapus seluruh token, sehingga `build()` berikutnya membaca `null` dan guard route mengarahkan kembali ke `/login`.

---

### Praktikum 2: FCM, Permission, dan Token Lifecycle

#### Hasil Implementasi

| Token FCM (Terpotong) di Halaman Debug | Notifikasi Masuk dari Firebase Console |
|---|---|
| ![Token Debug](screenshots/praktikum2-token-debug.png) | ![FCM Console Test](screenshots/fcm-console-test.png) |

#### Analisis

Notifikasi yang berhasil masuk ke panel sistem Android saat aplikasi berjalan di background membuktikan bahwa pendaftaran token dan topik ke FCM sudah berfungsi dengan benar, serta mengonfirmasi bahwa project Firebase (package name, `google-services.json`, dan konfigurasi Gradle) sudah terpasang secara tepat.

---