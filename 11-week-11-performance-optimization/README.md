# LAPORAN PRAKTIKUM - WEEK 11 OPTIMASI PERFORMA

## Identitas Mahasiswa

| Keterangan | Detail |
|---|---|
| Nama | Mufliha Hafsyah Shahieza |
| NIM | 244107020147 |
| Kelas | TI-3G |

---

## Deskripsi Project
Project ini adalah kelanjutan dari Week 10 (Integrasi Fitur AI). Pada Week 11, fokus pekerjaan adalah **Optimasi Performa** pada fitur AI Chat dan OCR. Prosesnya mengikuti alur jobsheet: mulai dari *profiling* dengan Flutter DevTools, mengidentifikasi masalah, menerapkan optimasi, memverifikasi hasil, hingga melakukan *memory profiling*.

**Stack:** Flutter, Riverpod, GoRouter, `http`, `flutter_secure_storage`, `flutter_markdown`, `image_picker`.

---

### Langkah 1: Baseline Profiling

Dilakukan profiling awal pada project menggunakan Flutter DevTools dengan mode `--profile`. 
- **Skenario Uji:** Buka Chat → Scroll cepat → Ketik pesan → Kirim pesan (tunggu AI membalas) → Buka OCR → Pilih gambar → Kembali ke Chat.
- **Baseline Metrics:** Rata-rata FPS hanya **40 FPS** dengan **4 Jank Frames** (frame merah). Average frame time ~24.5 ms.
- **Top Fungsi di Flame Chart:** `MarkdownBody.build` dan `Image.decode` (penumpukan tugas di Raster Thread).

**Bukti Profiling (Before):**<br>
![Before Profile](screenshots/before-profile.png)<br>

*Detail Flame Chart (Before) - Terlihat "Raster Jank Detected":*<br>
![Before Detail](screenshots/before-detail-jank.png)

---

### Langkah 2: Identifikasi Masalah

Berdasarkan hasil profiling, diidentifikasi 3 masalah utama yang tertulis lengkap di [`docs/performance-findings.md`](docs/performance-findings.md):
1. **Raster Jank saat Balasan AI Muncul:** DevTools mendeteksi masalah di Raster Thread (GPU) saat widget chat baru muncul. Hal ini disebabkan oleh proses rendering teks Markdown yang berat.
2. **Raster Jank saat Buka Gambar OCR:** Proses *decode* gambar beresolusi tinggi di halaman OCR membebani GPU.
3. **Rebuild Berlebih:** Kurangnya penggunaan widget `const` di area chat input dan *typing indicator* yang memicu rebuild berulang saat mengetik.

---

### Langkah 3: Terapkan Optimasi

Untuk mengatasi masalah di atas, diterapkan 3 teknik optimasi pada kode sumber:
1. **`RepaintBoundary` pada Chat Bubble:** Membungkus gelembung balasan AI di `chat_screen.dart`. Ini mengisolasi proses *repaint* teks Markdown yang berat agar tidak memicu render ulang seluruh layar (mengatasi Raster Jank).
2. **`cacheWidth` pada Gambar OCR:** Menambahkan parameter `cacheWidth: 800` pada `Image.file` di `ocr_screen.dart`. Ini memaksa Flutter melakukan *decode* gambar di resolusi yang lebih kecil, sehingga meringankan kerja GPU.
3. **`const` Constructor:** Menambahkan `const` pada widget statis (seperti `CircleAvatar` dan `SizedBox`) untuk mencegah proses *rebuild* yang tidak perlu setiap kali ada perubahan state.

---

### Langkah 4: Verifikasi Profiling

Setelah optimasi diterapkan, dilakukan *profiling* ulang dengan skenario yang sama persis.
- **Hasil After:** Rata-rata FPS naik signifikan dari 40 FPS menjadi **58 FPS**. *Jank frames* (bar merah) berkurang drastis menjadi 2, dan UI terasa jauh lebih mulus saat AI membalas chat.

**Bukti Flame Chart (After):**<br>
![After Profile](screenshots/after-profile.png)

*(Opsional - Detail After)*:<br>
![After Detail](screenshots/after-detail-jank.png)

---

### Langkah 5: Memory Profiling

Dilakukan pengecekan memori menggunakan tab **Memory** di DevTools dengan melakukan navigasi bolak-balik (Chat → OCR → Chat) sebanyak 5 kali.
- **Hasil:** Grafik memori stabil dan tidak menanjak. Tidak ditemukan indikasi *memory leak* (kebocoran memori). Seluruh *Controller* dan *Listener* sudah dibersihkan dengan benar pada method `dispose()`.

**Bukti Memory Profile:**<br>
![Memory Profile](screenshots/memory-profile.png)

---

### Tugas dan Refleksi

**Mini project / Industry Challenge:**
1. **Fitur Optimasi:** Berhasil menerapkan 3 teknik optimasi performa pada project AI Chat & OCR.
2. **Dokumentasi:** Laporan temuan (*findings*) terdokumentasi di `docs/performance-findings.md` dan laporan hasil optimasi di `docs/performance-report.md`.
3. **Bukti Hijau:** `flutter analyze` bersih (No issues found) dan `flutter test` lulus (All tests passed).
4. **Push Repo:** Folder `11-week-11-performance-optimization/` berisi `lib/`, `docs/`, `README.md`, dan `screenshots/`.

**Hasil Analyze & Test:**<br>
![Analyze dan Test](screenshots/flutter-analyze-test.png)

---

## Refleksi

1. **Optimasi mana yang memberikan dampak terbesar dan mengapa?**<br>
Jawaban:<br>
Optimasi yang memberikan dampak terbesar adalah kombinasi dari **`RepaintBoundary` pada Chat Bubble** dan **`cacheWidth` pada gambar OCR**. Sebelumnya, ketika AI membalas pesan, Flutter harus me-render ulang seluruh teks Markdown yang berat, memicu *Raster Jank* (frame merah). Dengan `RepaintBoundary`, render teks diisolasi sehingga tidak mengganggu frame UI utama. Sementara `cacheWidth` menyelesaikan masalah memori GPU yang *overload* saat membaca gambar galeri beresolusi tinggi. Hasilnya, FPS melonjak dari 40 menjadi 58.

2. **Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?**<br>
Jawaban:<br>
Saya memverifikasinya menggunakan Flutter DevTools pada mode `--profile`. Saya merekam skenario yang identik (buka chat, kirim pesan, buka OCR) sebelum dan sesudah optimasi. Metrik yang dibandingkan bukan sekadar perasaan "lebih cepat", melainkan data kuantitatif: penurunan jumlah *jank frames* (bar merah), kenaikan angka rata-rata FPS dari 40 ke 58, dan pengecekan tab Memory untuk memastikan tidak ada kebocoran.

3. **Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?**<br>
Jawaban:<br>
Menambahkan `RepaintBoundary` dan melakukan ekstraksi widget sedikit menambah jumlah baris kode dan membuat hierarki *widget tree* menjadi lebih dalam. Selain itu, penggunaan `cacheWidth` pada gambar membuat gambar sedikit kehilangan ketajaman jika di-*zoom* secara berlebihan. Namun, *trade-off* ini sepadan dengan kelancaran aplikasi yang jauh lebih baik dan penghematan memori yang signifikan.

4. **Kapan sebaiknya optimasi premature dihindari?**<br>
Jawaban:<br>
Optimasi *premature* sebaiknya dihindari saat aplikasi masih dalam tahap awal pengembangan (prototyping) atau ketika daftar datanya masih sangat sedikit (misal di bawah 10 item). Menerapkan optimasi kompleks sebelum ada masalah performa yang terbukti lewat *profiling* hanya akan membuat kode lebih sulit dibaca dan di-*maintain*. Prinsipnya: *"Profile first, then optimize."* Optimasi baru dilakukan saat DevTools benar-benar menunjukkan adanya penurunan FPS atau pemborosan memori.