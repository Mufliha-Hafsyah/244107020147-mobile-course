/// Mengambil id catatan dari path parameter rute `/note/:id`.
int parseNoteId(String raw) => int.parse(raw);

/// Menentukan tab aktif di MainShell dari lokasi rute saat ini.
/// 0 = Catatan, 1 = Posts.
int tabIndexForLocation(String location) =>
    location.startsWith('/posts') ? 1 : 0;
