# Performance Report — Week 11

## 1. Baseline Metrics (Before)
Berdasarkan profiling menggunakan Flutter DevTools (mode `--profile`):
- **Rata-rata FPS:** 40 FPS
- **Jank Frames (Merah):** 4 frame
- **Average Frame Time:** ~24.5 ms (melebihi budget 16.67 ms untuk 60 FPS)
- **Top Fungsi di Flame Chart:** `MarkdownBody.build` dan `Image.decode` (terjadi penumpukan tugas di Raster Thread).
- **Temuan:** Terjadi "Raster Jank" parah saat AI menjawab chat (karena render Markdown berat) dan saat memuat gambar OCR (karena resolusi besar).

## 2. Optimasi yang Diterapkan
1. **Chat Screen:** Membungkus gelembung chat (terutama yang berisi Markdown AI) dengan `RepaintBoundary` agar tidak memicu repaint seluruh layar.
2. **OCR Screen:** Menambahkan `cacheWidth: 800` pada `Image.file` agar GPU tidak bekerja keras melakukan decode gambar resolusi penuh.
3. **Chat Screen:** Menambahkan `const` pada widget statis (seperti `CircleAvatar`) untuk mencegah rebuild yang tidak perlu.

## 3. Hasil Verifikasi (After)
- **Rata-rata FPS:** Meningkat menjadi 58 FPS.
- **Jank Frames (Merah):** Berkurang drastis (hanya tersisa 2 bar di akhir).
- **Kesimpulan:** UI terasa jauh lebih mulus. *Raster Jank* saat AI membalas chat sudah tidak muncul lagi.

## 4. Memory Profiling
- Dilakukan uji navigasi bolak-balik (Chat -> OCR -> Chat) sebanyak 5 kali.
- **Hasil:** Grafik memori stabil (flat), tidak ada *memory leak*. Controller dan listener sudah di-dispose dengan benar.