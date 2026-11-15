import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../ai/ai_service.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Bagian Mode Gelap ---
          darkModeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(messageFromError(err))),
            data: (isDark) => SwitchListTile(
              title: const Text('Mode Gelap'),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),

          const Divider(height: 32),

          // --- Bagian API Key AI ---
          const Text(
            'Pengaturan AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan Google Gemini API Key untuk mengaktifkan fitur AI Chat.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // FutureBuilder untuk mengecek apakah API Key sudah tersimpan atau belum
          FutureBuilder<bool>(
            future: AiService().hasApiKey(),
            builder: (context, snapshot) {
              final hasKey = snapshot.data ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      hintText: hasKey
                          ? 'API Key sudah tersimpan'
                          : 'AIzaSy...',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.key),
                    ),
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        await AiService().saveApiKey(value);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('API Key berhasil disimpan!'),
                            ),
                          );
                          // Refresh tampilan agar status hasKey berubah
                          (context as Element).markNeedsBuild();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Tombol Hapus hanya muncul jika API Key sudah ada
                  if (hasKey)
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AiService().deleteApiKey();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('API Key berhasil dihapus.'),
                            ),
                          );
                          (context as Element).markNeedsBuild();
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Hapus API Key',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
