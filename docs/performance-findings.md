# Performance Findings — Week 11

## Metodologi
- Mode: `flutter run --profile`
- Device: Emulator Android (arm64)
- Skenario: Buka Chat -> Scroll -> Ketik -> Kirim pesan -> Buka OCR -> Pilih gambar -> Kembali ke Chat -> Scroll.

## Baseline Metrics (Before)
- Average FPS: 40 FPS
- Jank Frames (merah): 4 frame
- Temuan DevTools: Muncul "Raster Jank Detected" saat AI selesai menjawab chat.
- UI Phase: Paint ~0.9 ms (aman).
- Raster Phase: Bottleneck (Data not available, tapi terdeteksi Jank).

## Temuan Masalah
1. **Raster Jank saat Balasan AI Muncul:** DevTools mendeteksi masalah di Raster Thread (GPU) saat widget chat baru muncul. Hal ini disebabkan oleh proses rendering teks Markdown yang berat atau animasi *typing indicator*.
2. **Raster Jank saat Buka Gambar OCR:** Proses decode gambar beresolusi tinggi di halaman OCR membebani GPU.
3. **Rebuild Berlebih:** Kurangnya penggunaan widget `const` pada area chat input dan *typing indicator* yang memicu *rebuild* berulang saat mengetik.