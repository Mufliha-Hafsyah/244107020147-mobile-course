import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/chat/chat_screen.dart';

void main() {
  group('Pengujian Widget ChatScreen', () {
    testWidgets('Menampilkan teks sapaan awal dan tombol input', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('AI Chat Asisten'), findsOneWidget);
    });

    testWidgets('Bisa ngetik pesan dan muncul di chat', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      await tester.enterText(find.byType(TextField), 'Halo AI');

      await tester.tap(find.byIcon(Icons.send));

      await tester.pump();

      expect(find.text('Halo AI'), findsOneWidget);
    });
  });
}
