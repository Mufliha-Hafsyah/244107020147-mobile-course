# LAPORAN PRAKTIKUM - WEEK 2 PEMROGRAMAN MOBILE

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## JOBSHEET WEEK 2 Declarative UI & Responsive Design

---
### Praktikum: layout sederhana (warm-up)

#### Kondisi normal (setelah data diisi)
![Normal](screenshots/praktikum4-warmup-normal.png) <br>

Kartu tampil rapi, terpusat di layar, dengan avatar, nama, NIM, dan Kelas sesuai pola `Row` + `Expanded`.

### Eksperimen warm-up
#### Eksperimen 1 — Menghapus Expanded pada baris nama
![Overflow](screenshots/praktikum4-tanpa-expanded.png)<br>

Ketika teks nama diperpanjang secara signifikan, muncul garis kuning-hitam (overflow warning).

**Analisis:** <br>
Tanpa `Expanded`, `Row` memberi `Column` di dalamnya ukuran *natural/unconstrained*, dia mencoba menampilkan kontennya selebar yang dibutuhkan, bukan dibatasi sisa ruang yang tersedia. Jika lebar natural itu melebihi sisa ruang di `Row`, terjadi overflow karena `Row` tidak bisa memaksa child mengecil tanpa `Expanded` atau `Flexible`.<br>

![Overflow](screenshots/praktikum4-dengan-expanded.png)<br>
Sebaliknya, dengan `Expanded`, `Row` membatasi lebar `Column` sesuai sisa ruang yang tersedia. Karena `Text` secara default bisa wrap, begitu lebarnya dibatasi, teks otomatis pindah ke baris berikutnya (multi-line) alih-alih meluber keluar batas layout.

#### Eksperimen 2 — Menghapus mainAxisSize: MainAxisSize.min
![Tanpa MainAxisSize Min](screenshots/praktikum4-tanpa-mainaxissize-min.png)<br>

**Analisis:** <br>
`MainAxisSize.min` membuat `Column` hanya meminta tinggi minimum yang dibutuhkan kontennya. Setelah dihapus, default-nya menjadi `MainAxisSize.max`, sehingga `Column` mengambil seluruh tinggi yang tersedia dari parent (`Container` yang dipusatkan dalam `Scaffold` seukuran layar). Akibatnya, kartu melebar mengisi seluruh tinggi layar meski isinya hanya beberapa baris teks.<br> 
Hal ini menunjukkan pentingnya `MainAxisSize.min` ketika kita ingin sebuah container/kartu membungkus rapat kontennya, bukan ikut memenuhi ruang parent yang jauh lebih besar.

#### Eksperimen 3 — Menambahkan Baris Data (Email)
![Tambah Email](screenshots/praktikum4-tambah-email.jpeg)<br>

**Analisis:**<br>
Pola `Row` + `Expanded` bersifat reusable, menambah baris data baru cukup dengan menduplikasi struktur yang sama tanpa mengubah bagian lain. Tinggi kartu bertambah otomatis mengikuti jumlah konten karena `MainAxisSize.min` masih aktif.

#### Kesimpulan 
- `Expanded` di dalam `Row`/`Column` berfungsi memberi batas ruang (constraint) ke child-nya, mencegah overflow sekaligus memungkinkan teks untuk wrap ketika kontennya panjang.
- `MainAxisSize.min` penting digunakan ketika sebuah `Column`/`Row` harus membungkus rapat kontennya, bukan ikut memenuhi ruang parent yang lebih besar.
kut memenuhi ruang parent yang lebih besar.
- Pola `Row` + `Expanded` (label kiri, value kanan) bersifat reusable untuk menambah baris data baru tanpa perlu mengubah struktur widget lainnya.

---
### Praktikum: dashboard responsif 

#### Hasil Implementasi Pada Layar Sempit
![Sempit Light](screenshots/praktikum5-dashboard-sempit-light.png)<br>
![Sempit Dark](screenshots/praktikum5-dashboard-sempit-dark.png)<br> 
Menampilkan 1 kolom, kartu tersusun vertikal.

#### Hasil Implementasi Pada Layar Lebar
![Lebar Light](screenshots/praktikum5-dashboard-lebar-light.png)<br>
![Sempit Dark](screenshots/praktikum5-dashboard-lebar-dark.png)<br> 
Menampilkan 2 kolom sejajar, sesuai breakpoint `700px`.<br>

**Analisis:**<br>
`LayoutBuilder` memberi akses ke `constraints` dari parent, sehingga jumlah kolom bisa dihitung ulang secara reaktif setiap kali ukuran layar berubah (misal rotasi layar), tanpa perlu logic imperative untuk mendeteksi perubahan orientasi secara manual.

#### Mengubah DashboardApp dari StatelessWidget menjadi StatefulWidget
![Toggle Light](screenshots/praktikum5-toggle-light.png)<br>
![Toggle Dark](screenshots/praktikum5-toggle-dark.png)<br>
`CupertinoSwitch` berhasil mengubah tema aplikasi secara manual, terlepas dari setting sistem. Berbeda dengan praktikum sebelumnya yang mengikuti `ThemeMode.system`.

### Eksperimen Layout
#### Eksperimen 1 - Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.
Breakpoint diturunkan dari `700` ke `350`<br>
![Eksperimen Layout](screenshots/praktikum5-eksperimen1.png)<br>
Grid berubah menjadi 2 kolom bahkan pada layar HP potret. Ini menunjukkan breakpoint yang terlalu rendah membuat kartu menjadi terlalu sempit dan kurang nyaman dibaca, breakpoint 700px lebih sesuai untuk membedakan HP vs tablet.

#### Eksperimen 2 - Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system.
![Eksperimen Layout](screenshots/praktikum5-eksperimen2.1.png)<br>
![Eksperimen Layout](screenshots/praktikum5-eksperimen2.2.png)<br>
`CupertinoSwitch` tetap bisa ditoggle (state `isDark` berubah, ikon ikut berganti), namun tampilan tema aplikasi tidak ikut berubah atau tetap gelap terus. Ini adalah bukti nyata prinsip **declarative UI**: `build()` menggambarkan UI berdasarkan konfigurasi yang di-*declare* saat itu (dalam kasus ini `ThemeMode.dark` yang di-hardcode), bukan berdasarkan histori interaksi pengguna. Setelah `themeMode` dikembalikan menjadi dinamis (`isDark ? ThemeMode.dark : ThemeMode.light`), switch dan tema kembali sinkron.

#### Eksperimen 3 - Uji aplikasi dengan ukuran layar emulator yang berbeda.
- Layar Potrait 
![Eksperimen Layout](screenshots/praktikum5-dashboard-sempit-light.png)<br>
- Layar Landscape
![Eksperimen Layout](screenshots/praktikum5-dashboard-lebar-light.png)<br>

#### Eksperimen 4 - Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.
![Eksperimen Layout](screenshots/praktikum5-semantics-card.png)<br>
- `DashboardCard` dibungkus `Semantics` dengan `label: '$title: $value'`, agar screen reader membaca `title` dan `value` sebagai satu kalimat utuh (misal "Assignments: 8"), bukan dua teks terpisah tanpa konteks.
![Eksperimen Layout](screenshots/praktikum5-semantics-switch.png)<br>
- `CupertinoSwitch` dibungkus `Semantics` dengan `label` dinamis (menjelaskan status saat ini dan aksi yang akan terjadi jika ditekan) dan `toggled: isDark`, agar screen reader membacakan konteks yang jelas, bukan sekadar "switch".

#### Kesimpulan 
- `LayoutBuilder` memungkinkan UI merespons ukuran layar secara reaktif berdasarkan `constraints`, cocok untuk membangun layout responsif tanpa logic manual mendeteksi orientasi.
- Breakpoint harus dipilih sesuai target device, breakpoint yang terlalu rendah membuat layout lebar tampil pada layar yang sebenarnya sempit.
- `themeMode` yang di-hardcode memutus hubungan antara state UI dan tampilan tema. Menegaskan bahwa dalam declarative UI, tampilan akhir bergantung penuh pada apa yang dideklarasikan di `build()`.
- `Semantics` penting untuk aksesibilitas meski tidak berdampak visual, karena memberi konteks yang jelas bagi pengguna screen reader.

---






