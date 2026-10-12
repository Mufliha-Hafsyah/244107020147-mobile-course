import '../../../../core/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleDarkMode {
  const ToggleDarkMode(this._repository);
  final SettingsRepository _repository;

  Future<({bool darkMode, Failure? failure})> call() async {
    final loaded = await _repository.load();
    final current = loaded.settings.darkMode;
    if (loaded.failure != null) {
      return (darkMode: current, failure: loaded.failure);
    }
    final next = !current;
    final failure = await _repository.saveDarkMode(next);
    if (failure != null) return (darkMode: current, failure: failure);
    return (darkMode: next, failure: null);
  }
}