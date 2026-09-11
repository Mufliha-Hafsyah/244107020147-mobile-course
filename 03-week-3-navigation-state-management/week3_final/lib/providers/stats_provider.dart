import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef StatsFetcher = Future<List<String>> Function();

Future<List<String>> defaultStatsFetcher() async {
  await Future.delayed(const Duration(seconds: 2));
  final isFailure = DateTime.now().millisecondsSinceEpoch % 10 < 3;
  if (isFailure) {
    throw Exception('Gagal mengambil data statistik dari server');
  }
  return ['Pengguna aktif: 1.240', 'Rata-rata sesi: 8 menit', 'Retensi: 76%'];
}

class StatsNotifier extends AsyncNotifier<List<String>> {
  StatsNotifier({StatsFetcher? fetcher}) : _fetcher = fetcher ?? defaultStatsFetcher;
  final StatsFetcher _fetcher;

  @override
  Future<List<String>> build() async => _fetcher();
    
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetcher);
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(() => StatsNotifier());