/// Mengambil id catatan dari path parameter rute `/note/:id`.
int parseNoteId(String raw) => int.parse(raw);

/// Menentukan tab aktif di MainShell dari lokasi rute saat ini.
/// 0 = Catatan, 1 = Posts.
int tabIndexForLocation(String location) {
  if (location.startsWith('/posts')) return 1;
  if (location.startsWith('/chat')) return 2;
  return 0;
}
