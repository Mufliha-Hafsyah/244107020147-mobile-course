import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Center(
        child: Text(
          'Anda membuka pengumuman dengan id: $id',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}