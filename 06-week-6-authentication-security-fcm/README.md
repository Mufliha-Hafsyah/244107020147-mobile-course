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

### Praktikum 3: Payload, Tiga App State, Klik dan Topik

#### Matriks Pengujian

| State | Yang diharapkan | Cara uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console | ![Uji Foreground](screenshots/praktikum3-foreground.gif) |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik notifikasi | ![Uji Background](screenshots/praktikum3-background.gif) |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik notifikasi | ![Uji Terminated](screenshots/praktikum3-terminated.gif) |

#### Topic Messaging

| Target: Topic di Firebase Console | Notifikasi Diterima |
|---|---|
| ![Topic Target](screenshots/praktikum3-topic-target.png) | ![Topic Received](screenshots/praktikum3-topic-received.png) |

Subscribe ke topik `pengumuman-kampus` dilakukan otomatis saat `initFcmToken()` dipanggil (Praktikum 2). Pengujian ini membuktikan notifikasi tetap sampai ke device meski dikirim lewat topic, bukan langsung ke token aplikasi, cocok dipakai untuk pesan broadcast seperti pengumuman seluruh mahasiswa.

#### Analisis

Ketiga app state berhasil diuji dengan payload gabungan `notification + data`, membuktikan bahwa `data.route` konsisten tersedia dan dapat diproses baik oleh handler foreground (`onMessage`), klik dari background (`onMessageOpenedApp`), maupun saat aplikasi dibuka dari kondisi mati total (`getInitialMessage`). Bug `pendingDeepLink` yang ditemukan pada percobaan pertama Uji Foreground menunjukkan pentingnya menguji klik notifikasi pada kondisi nyata, bukan hanya memastikan notifikasi tampil di layar, modul secara eksplisit menyebut hal ini sebagai salah satu bug FCM paling mahal yang tidak terlihat hanya dari membaca kode.

---
### AI Prompt Challenge

Dokumentasi lengkap (prompt, output awal AI, audit checklist, dan perbandingan dengan implementasi manual) ada di:

[docs/ai-verification.md](docs/ai-verification.md)

---
### Refactoring Challenge

#### Hasil Implementasi

![Login Error setelah Refactor](screenshots/refactor-login-error.png)

#### Analisis

Rute yang dipusatkan ke kelas `Routes` mengurangi risiko salah ketik path dan mempermudah perubahan struktur URL di masa depan. Mapping error Dio yang dipindah ke `api_errors.dart` membuat pesan error bisa dipakai ulang tanpa duplikasi logic di halaman lain.

---