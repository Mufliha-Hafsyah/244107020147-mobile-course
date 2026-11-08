import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = tabIndexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) {
            context.go('/');
          } else if (i == 1) {
            context.go('/posts');
          } else if (i == 2) {
            context.go('/chat');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Catatan'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Cache Posts'),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}
