sealed class Failure {
  const Failure(this.message, {this.cause});

  /// Pesan ramah pengguna. Satu-satunya bagian yang boleh sampai ke UI.
  final String message;

  /// Penyebab asli untuk debugging, tidak untuk ditampilkan.
  final Object? cause;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message, {super.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

/// Pembungkus agar Failure bisa masuk ke AsyncError di presentation.
class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => failure.message;
}

/// UI hanya menerima message, tidak pernah exception mentah.
String messageFromError(Object error) {
  if (error is FailureException) return error.failure.message;
  return 'Terjadi kesalahan tak terduga. Coba lagi.';
}