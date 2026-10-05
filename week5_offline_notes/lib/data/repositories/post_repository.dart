import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../remote/post.dart';

/// Pintu cache/remote posts saja. Tidak mengurus tabel `notes`.
class PostRepository {
  PostRepository({required this.openDb, Dio? dio}) : _dio = dio ?? Dio();

  final Future<Database> Function() openDb;
  final Dio _dio;

  static const _endpoint = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> getCachedPosts() async {
    final db = await openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map(Post.fromMap).toList();
  }

  /// Hapus + insert dalam transaksi + batch agar atomik dan cepat.
  Future<void> cachePosts(List<Post> posts) async {
    final db = await openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final post in posts) {
        batch.insert('cached_posts', post.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Post>> fetchRemotePosts() async {
    final response = await _dio.get<List<dynamic>>(_endpoint);
    final data = response.data ?? [];
    return data
        .map((e) => Post.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
