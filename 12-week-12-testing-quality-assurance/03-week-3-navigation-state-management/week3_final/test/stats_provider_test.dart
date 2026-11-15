import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_final/providers/stats_provider.dart';

void main() {
  test('statsProvider berhasil memuat data ketika fetcher sukses', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(fetcher: () async => ['Item A', 'Item B', 'Item C']),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(statsProvider.future);
    expect(result, ['Item A', 'Item B', 'Item C']);
  });
}