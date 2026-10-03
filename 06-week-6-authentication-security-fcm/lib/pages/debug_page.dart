import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenPreview = ref.watch(fcmTokenPreviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Center(
        child: Text(
          tokenPreview == null
              ? 'Token belum tersedia'
              : 'FCM Token: $tokenPreview',
        ),
      ),
    );
  }
}