import 'package:go_router/go_router.dart';
import 'pages/notes_page.dart';
import 'pages/posts_cache_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/settings_page.dart';
import 'pages/main_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const NotesPage()),
        GoRoute(path: '/posts', builder: (context, state) => const PostsCachePage()),
      ],
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return NoteDetailPage(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);