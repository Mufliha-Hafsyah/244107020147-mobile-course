import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  final _storage = const FlutterSecureStorage();
  final _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent';

  final Future<String> Function(String prompt)? _fakeAsk;

  AiService({this._fakeAsk});

  bool isValidPrompt(String prompt) {
    return prompt.trim().isNotEmpty;
  }

  Future<String> _sendRequest(List<Map<String, dynamic>> parts) async {
    final apiKey = await _storage.read(key: 'ai_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode({
        'contents': [
          {'parts': parts},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }

  Future<String> ask(String question) async {
    if (_fakeAsk != null) {
      return _fakeAsk(question);
    }
    return _sendRequest([
      {'text': question},
    ]);
  }

  Future<String> askWithImage(String base64Image, String prompt) async {
    return _sendRequest([
      {
        'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
      },
      {'text': prompt},
    ]);
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key);
  }

  Future<bool> hasApiKey() async {
    final key = await _storage.read(key: 'ai_api_key');
    return key != null && key.isNotEmpty;
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: 'ai_api_key');
  }
}