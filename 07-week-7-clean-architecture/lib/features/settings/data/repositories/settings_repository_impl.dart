import '../../../../core/failures.dart';
import '../../../../data/prefs.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this._prefs});

  final PrefsRepository _prefs;

  @override
  Future<({AppSettings settings, Failure? failure})> load() async {
    try {
      final dark = await _prefs.getDarkMode();
      return (settings: AppSettings(darkMode: dark), failure: null);
    } catch (e) {
      return (
        settings: const AppSettings(),
        failure: LocalFailure('Gagal membaca pengaturan. Coba lagi.', cause: e),
      );
    }
  }

  @override
  Future<Failure?> saveDarkMode(bool value) async {
    try {
      await _prefs.setDarkMode(value);
      return null;
    } catch (e) {
      return LocalFailure('Gagal menyimpan pengaturan. Coba lagi.', cause: e);
    }
  }
}