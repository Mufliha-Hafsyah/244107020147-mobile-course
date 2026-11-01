# AI Log - Week 10 (Integrasi Fitur AI)

## 1. Alat AI
- **Asisten Coding AI:** Claude 
- **API Provider:** Google AI Studio (Gemini API).
- **Model API yang digunakan:** `gemini-3.1-flash-lite`.
- **Fitur yang dikerjakan:** AI Chat Assistant dengan UI gelembung chat, Markdown rendering, dan OCR (ekstraksi teks dari gambar).

## 2. Prompt (System & User Prompt)
- **System Prompt (Instruksi Chat):** "Kamu adalah asisten AI yang ramah, cerdas, dan menjawab dalam Bahasa Indonesia yang baik dan benar."
- **System Prompt (Instruksi OCR):** "Ekstrak semua teks yang ada di dalam gambar ini. Kembalikan hanya teksnya saja tanpa penjelasan tambahan."
- **User Prompt (Contoh Input):** "Jelaskan algoritma KNN itu apa."

## 3. Output Awal AI
AI berhasil memberikan respons yang sangat baik, namun pada tahap awal respons yang dikembalikan berupa teks mentah Markdown (mengandung `**` dan `###`). 
Selain itu, indikator loading awal masih berupa `CircularProgressIndicator` biasa, belum menyerupai *typing indicator* di aplikasi chat profesional.

## 4. Verifikasi dan Refactor
Saya tidak menerima output mentah tersebut. Tiga hal yang saya ubah:
1. **Markdown Rendering:** Menambahkan package `flutter_markdown` agar simbol `**` berubah menjadi teks tebal dan `###` menjadi header.
2. **Custom Loading:** Mengganti loading berputar dengan `_TypingIndicator` kustom (tiga titik bergerak naik turun) menggunakan `AnimationController`.
3. **OCR Support:** Menambahkan fungsi `askWithImage` di `AiService` dan mengubah gambar menjadi format *Base64* agar bisa dibaca oleh AI.

## 5. Evaluasi
Integrasi API berjalan sukses (HTTP 200). Pesan error 404 dari percobaan pertama berhasil diatasi dengan mengganti versi model ke `gemini-3.1-flash-lite`. Fitur Chat dan OCR sudah teruji berjalan dengan baik.