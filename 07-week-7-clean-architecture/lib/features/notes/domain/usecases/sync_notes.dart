import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({int synced, Failure? failure})> call() async {
    final counted = await _repository.countDirty();
    if (counted.failure != null) {
      return (synced: 0, failure: counted.failure);
    }
    if (counted.count == 0) return (synced: 0, failure: null);

    // Simulasi pengiriman ke server (belum ada backend tulis sungguhan).
    await Future.delayed(const Duration(seconds: 1));

    final failure = await _repository.markAllSynced();
    if (failure != null) return (synced: 0, failure: failure);
    return (synced: counted.count, failure: null);
  }
}