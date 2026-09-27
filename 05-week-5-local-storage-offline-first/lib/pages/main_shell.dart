import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.startsWith('/posts') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(i == 0 ? '/' : '/posts'),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Catatan'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Cache Posts'),
        ],
      ),
    );
  }
}