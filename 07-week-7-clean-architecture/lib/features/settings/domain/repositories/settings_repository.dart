import '../../../../core/failures.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<({AppSettings settings, Failure? failure})> load();
  Future<Failure?> saveDarkMode(bool value);
}
