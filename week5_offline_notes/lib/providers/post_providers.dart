import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/db.dart';
import '../data/remote/post.dart';
import '../data/repositories/post_repository.dart';
import '../data/sync.dart';
import 'offline_providers.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(openDb: openAppDatabase);
});

/// Empat kondisi cache-first:
/// 1. Offline + ada cache → kembalikan cache
/// 2. Offline + cache kosong → OfflineException
/// 3. Online + ada cache → kembalikan cache, refresh di background
/// 4. Online + cache kosong → fetch remote, cache, kembalikan
class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.watch(postRepositoryProvider);
    final offline = ref.watch(forceOfflineProvider);
    final cached = await repo.getCachedPosts();

    if (offline) {
      if (cached.isNotEmpty) return cached;
      throw OfflineException('Offline dan cache posts kosong');
    }

    if (cached.isNotEmpty) {
      Future<void>(() async {
        try {
          final remote = await repo.fetchRemotePosts();
          await repo.cachePosts(remote);
          state = AsyncData(remote);
        } catch (_) {
          // Biarkan cache yang sudah ditampilkan.
        }
      });
      return cached;
    }

    final remote = await repo.fetchRemotePosts();
    await repo.cachePosts(remote);
    return remote;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(postRepositoryProvider);
      final offline = ref.read(forceOfflineProvider);
      if (offline) {
        final cached = await repo.getCachedPosts();
        if (cached.isNotEmpty) return cached;
        throw OfflineException('Offline dan cache posts kosong');
      }
      final remote = await repo.fetchRemotePosts();
      await repo.cachePosts(remote);
      return remote;
    });
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);
