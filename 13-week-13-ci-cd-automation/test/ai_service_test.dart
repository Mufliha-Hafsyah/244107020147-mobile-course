import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/ai/ai_service.dart';

void main() {
  group('Pengujian Validasi Prompt AI', () {
    late AiService aiService;

    setUp(() {
      aiService = AiService();
    });

    test('Prompt berisi teks harus valid (True)', () {
      final result = aiService.isValidPrompt('Jelaskan tentang Flutter');
      expect(result, isTrue);
    });

    test('Prompt kosong harus tidak valid (False)', () {
      expect(aiService.isValidPrompt(''), isFalse);
    });

    test('Prompt hanya berisi spasi harus tidak valid (False)', () {
      expect(aiService.isValidPrompt('    '), isFalse);
    });

    test('Menggunakan fake API untuk respon sukses', () async {
      final fakeAiService = AiService(
        fakeAsk: (prompt) async => 'Halo dari Fake AI',
      );
      final result = await fakeAiService.ask('Halo');
      expect(result, 'Halo dari Fake AI');
    });

    test('Menggunakan fake API untuk respon error', () async {
      final fakeAiService = AiService(
        fakeAsk: (prompt) async => throw Exception('Koneksi Terputus'),
      );
      expect(() => fakeAiService.ask('Halo'), throwsA(isA<Exception>()));
    });
  });
}
