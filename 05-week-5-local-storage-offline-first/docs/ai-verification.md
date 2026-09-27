## AI Challenge

### AI Prompt Challenge
**Prompt yang Digunakan:**

```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

AI yang digunakan: Claude (chat assistant), sesuai kebijakan AI pada modul minggu ini yang memperbolehkan AI mengusulkan pilihan storage dengan syarat mahasiswa membandingkan trade-off dan mengambil keputusan sendiri.

---
### Output Awal AI

**Tabel Perbandingan 4 Opsi Storage:**

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada query — cuma get/set by key | Query sederhana (filter manual di Dart, tidak ada SQL) | Full SQL (WHERE, JOIN, ORDER BY, agregasi) | Full SQL + query builder type-safe di Dart |
| Kebutuhan relasi | Tidak mendukung relasi sama sekali | Tidak mendukung relasi native (box terpisah, manual link) | Mendukung relasi via foreign key manual | Mendukung relasi + referential integrity dideklarasikan di kode |
| Reaktivitas (stream) | Tidak ada, harus polling manual | Ada (`box.watch()`) tapi granular per box/key | Tidak ada bawaan — butuh polling atau trigger manual | Ada bawaan, `watch()` di level query hasil dari SQL |
| Type-safety | Rendah (get by key & type, rawan typo string) | Sedang (perlu adapter/codegen manual per objek) | Rendah (raw `Map<String, Object?>`, rawan salah kolom) | Tinggi (skema Dart digenerate jadi kelas & query type-safe) |
| Ukuran boilerplate | Sangat kecil | Kecil–sedang (perlu daftarkan adapter) | Sedang (SQL string manual + mapping toMap/fromMap) | Besar di awal (codegen, build_runner) tapi ringkas dipakai |
| Kemudahan testing | Mudah (bisa di-mock/fake instance) | Mudah-sedang (bisa pakai in-memory box) | Mudah dengan pola injeksi `openDb` | Mudah, driver in-memory bawaan untuk test |

**Tabel Rekomendasi Final:**

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi tema, waktu terakhir dibuka | SharedPreferences | Data primitif kecil, tidak butuh query/relasi, overhead minimal |
| CRUD catatan (koleksi, perlu urut, filter, sync) | sqflite (sesuai jobsheet); Drift disebut sebagai alternatif jangka panjang | sqflite cukup untuk skala jobsheet ini dan konsisten dengan materi; Drift unggul kalau butuh stream native dan skema besar |

**Skema Tabel untuk 1000+ Catatan:**

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

---
### Verifikasi menggunakan AI Verification Checklist

| Poin Checklist | Hasil Verifikasi |
|---|---|
| Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak. AI memisahkan preferensi ke SharedPreferences dan data koleksi ke sqflite, sesuai alasan bahwa SharedPreferences rapuh untuk koleksi data. |
| Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos? | Mendukung. Skema menyertakan kolom `dirty` dan `updated_at`, dengan index tambahan di kedua kolom untuk mempercepat `ORDER BY updated_at DESC` dan filter `WHERE dirty = 1`. |
| Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi? | Didukung dengan tepat. AI secara eksplisit menyatakan sqflite **tidak** punya stream bawaan (refresh manual via `ref.invalidate()`), dan hanya menyebut kemampuan stream native pada opsi Drift — tidak ada klaim "real-time" yang tidak berdasar. |
| Apakah estimasi boilerplate AI masuk akal setelah dicoba instalasinya (`flutter pub add` + migrasi skema)? | Dicoba langsung dengan menjalankan instalasi ketiga package pembanding. **Hive**: `flutter pub add hive hive_flutter` hanya menambah 2 baris di `dependencies:`, tanpa entri baru di `dev_dependencies:` — tidak butuh code generator. **Drift**: `flutter pub add drift sqlite3_flutter_libs path_provider` + `dev:drift_dev dev:build_runner` menambah 3 baris di `dependencies:` dan 2 baris di `dev_dependencies:` (total 5, lebih dari 2x lipat Hive). Setelah membuat 1 file tabel sederhana (6 baris definisi kolom) dan menjalankan `dart run build_runner build`, proses codegen memakan waktu **~83 detik** dan menghasilkan **555 baris kode otomatis** hanya untuk satu tabel kecil, tersebar di 24 file output. Estimasi AI ("Hive: kecil–sedang", "Drift: besar di awal tapi ringkas dipakai") terbukti akurat secara kuantitatif — rasio 6 baris kode manual berbanding 555 baris hasil generate menunjukkan boilerplate Drift memang jauh lebih berat di setup awal dibanding Hive maupun sqflite. |
| Keputusan final Anda beserta alasannya | Tetap memilih SharedPreferences + sqflite sesuai rekomendasi AI dan materi jobsheet, karena skala aplikasi (catatan pribadi, single user, tanpa kebutuhan relasi antar tabel) belum memerlukan reaktivitas stream native atau type-safety tingkat compile-time dari Drift. Bukti nyata (555 baris ter-generate, ~83 detik codegen untuk 1 tabel) memperkuat keputusan ini: biaya setup Drift belum sepadan untuk skala jobsheet ini, meski Drift tetap dipertimbangkan sebagai opsi migrasi bila ke depan aplikasi membutuhkan multi-tabel relasional dengan update real-time di banyak layar sekaligus. |

---
### Masalah yang Ditemukan dan Perbaikan

Tidak ditemukan masalah teknis pada tahap perbandingan konsep (tabel dan skema SQL dari AI benar dan konsisten). Namun ditemukan dua temuan di luar klaim AI, muncul dari percobaan instalasi langsung, bukan dari penjelasan tekstual AI:

1. **`sqlite3_flutter_libs: ^0.6.0+eol`** — versi yang terinstal otomatis oleh `flutter pub add` ditandai *end-of-life* oleh maintainer-nya, sesuatu yang tidak disebutkan AI saat merekomendasikan Drift.
2. **Flag `--delete-conflicting-outputs` deprecated** — flag ini umum disarankan di tutorial build_runner, tapi saat dijalankan pada `build_runner ^2.16.1` yang terinstal, muncul warning bahwa opsi tersebut sudah dihapus dan diabaikan.

---
### Edge Case / Pertimbangan Tambahan yang Ditambahkan Sendiri

Selain kriteria yang diminta pada prompt, ditambahkan pertimbangan biaya migrasi dan bukti kuantitatif boilerplate:

- **Biaya migrasi:** skema tabel `notes` yang sudah dirancang dengan kolom `dirty` dan `updated_at` dapat dipetakan langsung ke definisi tabel Drift tanpa perubahan struktur data, sehingga keputusan memakai sqflite saat ini tidak menutup opsi migrasi di masa depan.
- **Bukti kuantitatif boilerplate:** dibuktikan lewat percobaan nyata bahwa 6 baris definisi tabel Drift menghasilkan 555 baris kode otomatis dalam ~83 detik proses `build_runner`, dibanding Hive yang tidak memerlukan proses generate sama sekali.

---
### Hasil Akhir

Perbandingan `pubspec.yaml` sebelum dan sesudah instalasi:

| | Baris di `dependencies:` | Baris di `dev_dependencies:` |
|---|---|---|
| Hive | +2 (`hive`, `hive_flutter`) | +0 |
| Drift | +3 (`drift`, `sqlite3_flutter_libs`, `path_provider`) | +2 (`drift_dev`, `build_runner`) |

Output `dart run build_runner build` untuk 1 file tabel Drift (`notes_table.dart`, 6 baris definisi kolom):

```
Building package executable... (14.2s)
66s compiling builders/aot
16s drift_dev on 48 inputs: 12 skipped, 23 output, 13 no-op
Built with build_runner/aot in 83s with warnings; wrote 24 outputs.
```


File `notes_table.g.dart` hasil generate: **555 baris kode**.<br>

![BuildRunner](screenshots/ai-challenge-drift-buildrunner-terminal.png)<br>
![GeneratedCode](screenshots/ai-challenge-drift-generated-code.png)<br>

### Kesimpulan

Estimasi boilerplate dari AI terbukti akurat setelah diuji langsung: instalasi Drift butuh lebih dari 2x dependency dibanding Hive, dan proses `build_runner` menghasilkan 555 baris kode otomatis dari hanya 6 baris definisi tabel dalam waktu ~83 detik. Percobaan ini juga menemukan dua hal yang tidak disebutkan AI — versi package `sqlite3_flutter_libs` yang sudah *end-of-life*, dan flag CLI `--delete-conflicting-outputs` yang ternyata deprecated. Rekomendasi akhir tetap SharedPreferences + sqflite, karena skala aplikasi saat ini belum membutuhkan reaktivitas stream native atau biaya setup Drift yang jauh lebih berat.

---