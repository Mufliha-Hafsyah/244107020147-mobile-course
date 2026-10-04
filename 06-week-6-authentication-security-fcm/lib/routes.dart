class Routes {
  Routes._();

  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';
  static const announcementPrefix = '/pengumuman';

  static String announcement(String id) => '$announcementPrefix/$id';
}