import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_ai_challenge/providers/stats_provider.dart';

void main() {
  test('StatsNotifier mengembalikan data saat fetch berhasil', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(fetcher: () async => ['Data A', 'Data B', 'Data C']),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(statsProvider.future);

    expect(result, ['Data A', 'Data B', 'Data C']);
  });

  test('StatsNotifier menghasilkan AsyncError saat fetch gagal', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(fetcher: () async => throw Exception('Gagal')),
        ),
      ],
    );

    // Dengarkan provider agar proses build() benar-benar dijalankan.
    container.listen(statsProvider, (previous, next) {});

    // Beri kesempatan event loop menyelesaikan Future yang reject,
    // sebelum kita membaca state akhirnya.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(statsProvider);
    expect(state.hasError, isTrue);

    container.dispose();
  });
}