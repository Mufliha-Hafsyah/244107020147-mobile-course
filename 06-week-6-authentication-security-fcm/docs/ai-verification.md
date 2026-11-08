## AI Challenge

### AI Prompt Challenge 
**Prompt yang Digunakan**

```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

AI yang digunakan: Claude (chat assistant), sesuai kebijakan AI Minggu 6 yang mengizinkan AI membuat implementasi awal FCM, dengan syarat token lifecycle, jenis payload, dan perilaku tiga app state wajib diverifikasi manual.

---
### Output Awal AI

```dart
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  PushService(this._dio);
  final Dio _dio;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> backgroundHandler(RemoteMessage message) async {
    print('Background message: ${message.data}');
  }

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> init() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    await _dio.post('/devices', data: {'fcm_token': token});

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToRoute(message.data['route']);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToRoute(initialMessage.data['route']);
    }
  }

  void _navigateToRoute(String? route) {
    // Navigasi ditangani oleh GoRouter di main.dart.
  }

  Future<void> subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
  }

  Future<void> unsubscribeTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
  }
}
```

---
### Verifikasi Menggunakan AI Verification Checklist

| Poin Checklist | Hasil Verifikasi |
|---|---|
| Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`? | **Gagal.** `backgroundHandler` berupa method di dalam class `PushService`, bukan fungsi top-level. Tidak ada `@pragma('vm:entry-point')` sama sekali. Method kelas tidak akan bisa dipanggil dari isolate terpisah tempat background handler sungguhan berjalan. |
| `onTokenRefresh` benar-benar mengirim token baru ke backend? | **Gagal.** Token baru hanya dicetak lewat `print('Token refreshed: $newToken')`, tidak pernah dikirim ke `POST /devices`. Backend akan menyimpan token basi setelah token asli berubah. |
| Foreground memakai local notification manual? | **Gagal total, tidak ada sama sekali.** Kode AI tidak memiliki listener `FirebaseMessaging.onMessage` apa pun. Notifikasi tidak akan pernah tampil saat aplikasi dalam kondisi foreground. |
| Klik dari ketiga state masuk ke rute yang benar? | **Tidak dapat dibuktikan.** Fungsi `_navigateToRoute()` hanya berisi komentar kosong, tidak melakukan navigasi apa pun. Tanggung jawab navigasi dilempar ke "main.dart" tanpa mekanisme penyambungan nyata. |
| Token/secret tidak di-hardcode dan tidak di-log penuh? | **Gagal.** Baris `print('FCM Token: $token')` mencetak token lengkap ke console, melanggar prinsip keamanan dasar yang disebutkan eksplisit pada modul. |
| Penanda perbedaan Android 13+ vs iOS, dan larangan akses `BuildContext`? | **Tidak dipenuhi.** Tidak ada komentar atau penanganan apa pun terkait perbedaan platform maupun peringatan larangan `BuildContext` di background handler. |

**Ringkasan:** dari 6 poin checklist, 5 poin gagal total dan 1 poin tidak dapat dibuktikan karena implementasinya kosong.

---
### Perbandingan dengan Implementasi Manual

Karena tingkat kegagalan draf AI sangat tinggi, pendekatan yang diambil bukan memperbaiki kode AI ini, melainkan mendokumentasikan bahwa implementasi manual pada Praktikum 1–3 sudah menghindari seluruh kesalahan di atas sejak awal:

| Masalah pada Draf AI | Implementasi Manual yang Benar |
|---|---|
| `backgroundHandler` method kelas, tanpa `@pragma` | `firebaseMessagingBackgroundHandler` di `lib/messaging/push_service.dart` adalah fungsi top-level dengan `@pragma('vm:entry-point')`, didaftarkan lewat `registerBackgroundHandler()` di `main()`. |
| `onTokenRefresh` hanya `print()` | `initFcmToken()` meneruskan token baru ke callback `onToken` yang sama dengan token awal, memotongnya jadi 12 karakter dan menyimpannya ke `fcmTokenPreviewProvider`, siap diteruskan ke endpoint backend (ditandai dengan komentar `TODO` di `main.dart`). |
| Tidak ada `onMessage` / local notification manual | `listenForeground()` menangani `FirebaseMessaging.onMessage` dan menampilkan local notification lewat `_local.show(...)`, terbukti bekerja pada Uji Foreground (lihat Praktikum 3). |
| `_navigateToRoute()` kosong | `goToRoute()` di `main.dart` memakai `rootNavigatorKey.currentContext` untuk memanggil `GoRouter.of(ctx).go(route)` secara nyata, dan dipakai konsisten oleh `listenForeground`, `initLocalNotifications(onTapNotification: ...)`, maupun `handleTerminated`. Terbukti berhasil pada ketiga uji app state. |
| `print('FCM Token: $token')` mencetak token penuh | Token dipotong (`substring(0, 12)`) **sebelum** disimpan ke state, sehingga token penuh tidak pernah ada di memori aplikasi maupun log. Dibuktikan lewat `DebugPage` pada Praktikum 2. |
| Tidak ada penanda Android 13+ vs iOS / larangan `BuildContext` | Komentar eksplisit `// Jangan akses BuildContext / Riverpod di sini` disertakan pada `firebaseMessagingBackgroundHandler`, sesuai prinsip modul. |

---
## Kesimpulan

Sekilas draf `PushService` dari AI terlihat masuk akal karena semua nama method yang diminta prompt ada: `requestPermission`, `init`, `subscribeTopic`, dan seterusnya. Tapi begitu isi tiap method diperiksa satu per satu pakai checklist, ternyata banyak yang kosong, salah pola (dibuat method kelas, padahal seharusnya fungsi top-level), atau melanggar prinsip keamanan dasar seperti mencetak token penuh ke log.
<br><br>
Ini membuktikan apa yang sudah diingatkan di modul: bug FCM yang paling merepotkan (token basi, klik yang nyasar, notifikasi dobel) tidak akan ketahuan hanya dengan membaca kode. Draf ini kemungkinan besar akan lolos kalau cuma dicek sekilas, karena struktur dan nama methodnya meyakinkan, padahal begitu diuji langsung perilakunya di tiga app state, hasilnya jauh dari yang diharapkan.

---