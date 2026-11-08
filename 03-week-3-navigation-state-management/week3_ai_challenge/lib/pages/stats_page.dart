import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman yang menampilkan statistik, dengan penanganan tiga kondisi
/// AsyncValue: loading, error, dan success.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch dipakai di dalam build agar UI rebuild otomatis
    // setiap kali state statsProvider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Kondisi loading: tampilkan spinner di tengah layar.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Kondisi error: tampilkan pesan error + tombol retry.
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $err'),
              const SizedBox(height: 12),
              FilledButton(
                // ref.read dipakai di callback, bukan ref.watch,
                // karena kita hanya perlu memanggil method sekali.
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),

        // Kondisi success: tampilkan 3 item statistik dalam ListView.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}