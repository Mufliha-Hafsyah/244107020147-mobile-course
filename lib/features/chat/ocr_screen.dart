import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../ai/ai_service.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final _aiService = AiService();
  File? _image;
  String _result = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
      });
    }
  }

  Future<void> _extractText() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Baca gambar dan ubah ke Base64
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Panggil AI
      const prompt =
          "Ekstrak semua teks yang ada di dalam gambar ini. Kembalikan hanya teksnya saja tanpa penjelasan tambahan.";
      final result = await _aiService.askWithImage(base64Image, prompt);

      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR (Scan Teks)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          if (_image != null)
            Image.file(
              _image!,
              height: 200,
              cacheWidth: 800,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                ),
                ElevatedButton.icon(
                  onPressed: (_image != null && !_isLoading)
                      ? _extractText
                      : null,
                  icon: const Icon(Icons.text_snippet),
                  label: const Text('Ekstrak Teks'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
