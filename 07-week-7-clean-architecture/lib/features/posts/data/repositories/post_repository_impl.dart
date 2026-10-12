import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({Future<Database> Function()? openDb, Dio? dio})
      : _openDb = openDb ?? openNotesDb,
        _dio = dio ??
            Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

  final Future<Database> Function() _openDb;
  final Dio _dio;

  @override
  Future<({List<Post> posts, Failure? failure})> readCached() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = rows
          .map((row) => PostModel.fromJson(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>))
          .toList();
      return (posts: posts, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: LocalFailure('Gagal membaca data tersimpan.', cause: e),
      );
    }
  }

  @override
  Future<({List<Post> posts, Failure? failure})> refresh() async {
    final List<PostModel> fresh;
    try {
      final response = await _dio.get<List>('/posts');
      final data = response.data ?? [];
      fresh = data
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList();
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Tidak dapat terhubung ke server.', cause: e),
      );
    }

    try {
      final db = await _openDb();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final post in fresh) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
      return (posts: fresh, failure: null);
    } catch (e) {
      return (
        posts: fresh,
        failure: LocalFailure('Gagal menyimpan data ke perangkat.', cause: e),
      );
    }
  }
}