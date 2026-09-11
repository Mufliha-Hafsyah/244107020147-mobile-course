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

### Praktikum  2 — Aplikasi ToDo dengan Riverpod

**Kondisi awal (kosong):**<br>
![Kosong](screenshots/praktikum2-todo-kosong.png)<br>
**Dialog tambah tugas:**<br>
![Dialog Tambah](screenshots/praktikum2-todo-dialog-tambah.png)<br>
**List terisi:**<br>
![List](screenshots/praktikum2-todo-list.png)<br>
**Tugas dicentang (selesai):**<br>
![Checked](screenshots/praktikum2-todo-checked.png)<br>
**Tugas dihapus:**
![Delete](screenshots/praktikum2-todo-deleted.png)<br>

**Analisis:**<br>
- `ref.watch` yang dipanggil di dalam `build` menyebabkan `TodoPage` melakukan pembangunan ulang (rebuild) secara otomatis setiap kali `state` pada `TodoListNotifier` mengalami perubahan, baik akibat penambahan, pengubahan status (toggle), maupun penghapusan tugas. Hal ini merupakan konsekuensi dari prinsip *UI deklaratif = f(state)*, di mana tampilan antarmuka selalu merepresentasikan state terkini secara konsisten.
- Sebaliknya, `ref.read` yang digunakan di dalam callback (`onPressed`, `onChanged`) hanya melakukan pemanggilan method notifier satu kali tanpa mendaftarkan widget untuk menerima notifikasi perubahan state selanjutnya. Pendekatan ini mencegah terjadinya pembangunan ulang widget yang tidak diperlukan pada saat callback dieksekusi.
- Poin penting yang telah diverifikasi adalah bahwa seluruh method pada `TodoListNotifier` (`add`, `toggle`, `remove`) senantiasa menghasilkan objek atau list yang baru (`[...state, ...]`, `copyWith`, `[...state]..removeAt(...)`), bukan memodifikasi `state` secara langsung. Hal ini bersifat krusial karena Riverpod mendeteksi perubahan berdasarkan perbedaan referensi objek, bukan berdasarkan mutasi internal pada objek yang sama.

---