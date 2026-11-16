import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../data/prefs.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/toggle_dark_mode.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(prefs: PrefsRepository()),
);

final toggleDarkModeProvider = Provider<ToggleDarkMode>(
  (ref) => ToggleDarkMode(ref.watch(settingsRepositoryProvider)),
);

// Nama provider sengaja sama dengan versi lama supaya pemakainya
// (misalnya tema di main.dart) cukup mengganti import.
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.watch(settingsRepositoryProvider).load();
    if (result.failure != null) throw FailureException(result.failure!);
    return result.settings.darkMode;
  }

  Future<void> toggle() async {
    state = const AsyncLoading();
    final result = await ref.read(toggleDarkModeProvider)();
    if (result.failure != null) {
      state = AsyncError(FailureException(result.failure!), StackTrace.current);
      return;
    }
    state = AsyncData(result.darkMode);
  }
}
