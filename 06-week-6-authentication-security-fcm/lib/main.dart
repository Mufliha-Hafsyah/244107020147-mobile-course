import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'messaging/push_service.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();

  final container = ProviderContainer();

  void goToRoute(String route) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) GoRouter.of(ctx).go(route);
  }

  await requestNotificationPermission();
  await initLocalNotifications(onTapNotification: goToRoute);
  await initFcmToken(onToken: (token) async {
    final preview = token.length > 12 ? '${token.substring(0, 12)}...' : token;
    container.read(fcmTokenPreviewProvider.notifier).set(preview);
  });

  listenForeground(goToRoute);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await handleTerminated(goToRoute);
  });
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/debug', builder: (context, state) => const DebugPage()),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: ref.watch(routerProvider),
    );
  }
}