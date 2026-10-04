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
### Testing

**Hasil:**<br>
![Testing Passed](screenshots/testing-passed.png)

---
### Checklist Verifikasi Mandiri

**1. Access/refresh token disimpan di secure storage, bukan SharedPreferences.** <Br>
`TokenStore` (`lib/data/token_store.dart`) menggunakan `flutter_secure_storage`, dibuktikan dengan unit test `token_store_test.dart` dan uji persistensi token pada Praktikum 1.
<br>

**2. Interceptor Dio menukar refresh token otomatis saat menerima 401, dan mengulang request satu kali.**<br>
Diimplementasikan pada `buildApiClient()` (`lib/data/api_client.dart`), lihat Praktikum 1.
<br>

**3. Guard route mengarahkan ke `/login` saat pengguna belum login.**<br>

| Uji | Langkah | Hasil yang Diharapkan | Hasil |
|---|---|---|---|
| Token bertahan | Login berhasil, tutup aplikasi total dari recent apps, buka lagi | Langsung masuk Home tanpa login ulang  | ![Uji persistensi token](screenshots/praktikum1-uji-token-bertahan.gif) |
| Logout menghapus token | Tekan logout, tutup aplikasi total, buka lagi | Tetap di halaman Login | ![Uji persistensi token](screenshots/praktikum1-uji-logout-menghapus-token.gif) |
<br> 

**4. Token FCM ditampilkan terpotong, tidak pernah ditampilkan atau dicatat secara penuh.**<br>

![Token Debug](screenshots/praktikum2-token-debug.png)
<br>

**5. Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`.**<br>

Diimplementasikan pada `firebaseMessagingBackgroundHandler` (`lib/messaging/push_service.dart`), lihat Praktikum 3.
<br> 

**6. Notifikasi pada tiga app state (foreground, background, terminated) teruji dengan bukti nyata.**<br>

| State | Yang diharapkan | Cara uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console | ![Uji Foreground](screenshots/praktikum3-foreground.gif) |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik notifikasi | ![Uji Background](screenshots/praktikum3-background.gif) |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik notifikasi | ![Uji Terminated](screenshots/praktikum3-terminated.gif) |

<br>

**7. Topic messaging berfungsi.**<br>

| Target: Topic | Notifikasi Diterima |
|---|---|
| ![Topic Target](screenshots/praktikum3-topic-target.png) | ![Topic Received](screenshots/praktikum3-topic-received.png) |
<br>

**8. Hasil AI Prompt Challenge diverifikasi dan didokumentasikan pada folder `docs/`.** <br>

Dokumentasi lengkap (prompt, output awal AI, audit checklist, dan perbandingan dengan implementasi manual) ada di:<br>
[docs/ai-verification.md](docs/ai-verification.md)
<br>

**9. `flutter analyze` tanpa issue dan seluruh test lulus.**<br>
![Testing Passed](screenshots/testing-passed.png)

---
### Mini Project: Campus Notification App

Seluruh requirement mini project sudah terpenuhi melalui pengerjaan praktikum dan tantangan di atas:<br>

**1. Login (mock/Firebase Auth) dengan guard route: belum login selalu diarahkan ke /login.**<br>

Diimplementasikan pada `AuthRepository` dan `GoRouter.redirect`, dibuktikan lewat uji tutup-buka aplikasi pada Praktikum 1 (lihat Checklist poin 1 dan 3).<br>

**2.Token disimpan di secure storage; Dio otomatis refresh sekali saat 401 dan logout bila refresh mati.**<br>

`TokenStore` menggunakan `flutter_secure_storage`. Interceptor pada `buildApiClient()` menukar refresh token saat 401 dan mengulang request satu kali. Bila refresh ikut gagal, seluruh token dihapus lewat `store.clear()`. Perilaku ini diuji lewat unit test interceptor (di bagian testing).<br>

**3. FCM terintegrasi: permission, getToken + onTokenRefresh terkirim ke backend (atau didokumentasikan endpoint POST /devices), dan subscribe topik pengumuman-kampus.**<br>

`initFcmToken()` (`lib/messaging/push_service.dart`) meminta izin notifikasi, mengambil token awal, mendaftarkan listener `onTokenRefresh`, dan subscribe topic. Endpoint backend sungguhan belum tersedia (mock project), sehingga pengiriman token ditandai sebagai `TODO: kirim token ke backend sungguhan` dengan endpoint yang didokumentasikan sebagai `POST /devices` pada `main.dart`.
<br>

**4. Notifikasi gabungan notification + data; klik membuka /pengumuman/:id pada ketiga app state. Isi tabel pengujian foreground/background/terminated di README.**<br>
| State | Diharapkan | Cara Uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console | Berhasil |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik notifikasi | Berhasil |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik notifikasi | Berhasil |

<br>

| Foreground | Background | Terminated |
|---|---|---|
| ![Foreground](screenshots/praktikum3-foreground.gif) | ![Background](screenshots/praktikum3-background.gif) | ![Terminated](screenshots/praktikum3-terminated.gif) |

**5. Screenshot bukti (token terpotong, banner tiap state, halaman tujuan deep link) di folder screenshots/.**<br>

| Token Terpotong | Notifikasi Masuk | Halaman Tujuan Deep Link |
|---|---|---|
| ![Token Debug](screenshots/praktikum2-token-debug.png) | ![FCM Console Test](screenshots/fcm-console-test.png) | ![Announcement](screenshots/praktikum3-topic-received.png) |

Bukti lengkap untuk tiap app state (foreground, background, terminated) berupa rekaman, dapat dilihat pada Praktikum 3.<br><br>

**6. Sertakan minimal 2 test yang lulus (parsing route + logika sesi/refresh).**<br>

5 unit test pada `test/push_service_test.dart` (parsing `routeFromMessage`) dan `test/token_store_test.dart` (penyimpanan dan penghapusan token), lihat bagian Testing.
<br>

**7. Hasil AI Prompt Challenge terdokumentasi.**<br>

Lihat [`docs/ai-verification.md`](docs/ai-verification.md).<br>

**8. Push ke repository portfolio pada folder 06-week-6-authentication-security-fcm/ dengan struktur lib/, test/, docs/, README.md, dan screenshots/. README menjelaskan tujuan, fitur utama, stack teknologi, cara menjalankan, dan hasil yang dicapai.**<br>

Project ditempatkan di `06-week-6-authentication-security-fcm/` dengan struktur `lib/`, `test/`, `docs/`, `screenshots/`, dan `README.md` ini.

#### Cara Menjalankan

```bash
cd 06-week-6-authentication-security-fcm
flutter pub get
flutter run
```
<br>
Catatan: project ini membutuhkan file `android/app/google-services.json` dari project Firebase masing-masing untuk fitur FCM berfungsi. File ini sengaja tidak disertakan di repository karena bersifat sensitif.

---
## Refleksi

**1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**<br>

Jawaban:<br>
SharedPreferences menyimpan data dalam file XML biasa yang tidak terenkripsi, jadi kalau perangkat di-root atau diakses orang lain, isinya bisa langsung dibaca. Refresh token itu kredensial yang umurnya panjang dan bisa dipakai berkali-kali untuk minta access token baru, jadi kalau bocor, penyerang bisa terus menyamar jadi pengguna dalam waktu lama tanpa perlu login ulang atau tahu password, bahkan setelah access token lamanya kedaluwarsa. `flutter_secure_storage` menyimpan data terenkripsi lewat Keystore Android, sehingga jauh lebih sulit diambil.<br><br>

**2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?**<br>

Jawaban:<br>
Token FCM bisa berubah kapan saja, misalnya saat aplikasi di-reinstall, data aplikasi dihapus, atau ada rotasi token oleh sistem. Kalau listener `onTokenRefresh` tidak ada, backend kampus tetap menyimpan token lama yang sudah tidak valid, sehingga notifikasi pengumuman yang dikirim ke mahasiswa tersebut tidak akan pernah sampai lagi, padahal dari sisi aplikasi sepertinya semua baik-baik saja karena tidak ada error yang muncul. Selama satu semester, ini bisa berarti banyak mahasiswa diam-diam berhenti menerima notifikasi tanpa ada yang menyadarinya sampai ada yang komplain ketinggalan pengumuman penting.<br><br>

**3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.**<br>

Jawaban:<br>
Topic cocok dipakai untuk pesan broadcast yang ditujukan ke banyak orang sekaligus tanpa perlu tahu device masing-masing, misalnya pengumuman libur kampus atau perubahan jadwal UTS yang berlaku untuk semua mahasiswa yang subscribe topic `pengumuman-kampus`. Token perangkat dipakai untuk pesan personal yang hanya relevan untuk satu pengguna tertentu, misalnya notifikasi "Nilai UAS Pemrograman Mobile Anda sudah keluar" atau "Tagihan UKT Anda belum dibayar", yang jelas tidak boleh dikirim ke semua orang lewat topic.<br><br>

**4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**<br>

Jawaban:<br>
Draf `PushService` dari AI diverifikasi pakai AI Verification Checklist dan gagal di 5 dari 6 poin, sehingga ditolak seluruhnya dan tidak dipakai di project. Masalah utamanya: background handler ditulis sebagai method kelas tanpa `@pragma('vm:entry-point')`, `onTokenRefresh` cuma `print()` tanpa kirim ke backend, tidak ada listener `onMessage` sama sekali sehingga notifikasi tidak tampil saat foreground, fungsi navigasi kosong, dan token lengkap dicetak ke log. Karena tingkat kegagalannya tinggi, bukan draf ini yang diperbaiki, melainkan didokumentasikan sebagai perbandingan terhadap implementasi manual pada Praktikum 1–3 yang sejak awal sudah menghindari seluruh masalah tersebut.

---