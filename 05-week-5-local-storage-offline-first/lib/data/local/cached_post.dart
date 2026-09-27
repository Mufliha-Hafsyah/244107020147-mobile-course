class CachedPost {
  const CachedPost({required this.id, required this.title, required this.cachedAt});

  final int id;
  final String title;
  final DateTime cachedAt;
}