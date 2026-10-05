import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/data/remote/post.dart';
import 'package:week5_offline_notes/data/repositories/post_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/providers/offline_providers.dart';
import 'package:week5_offline_notes/providers/post_providers.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.cached = const []})
      : super(openDb: () => throw UnimplementedError());

  List<Post> cached;

  @override
  Future<List<Post>> getCachedPosts() async => List.from(cached);

  @override
  Future<void> cachePosts(List<Post> posts) async {
    cached = List.from(posts);
  }

  @override
  Future<List<Post>> fetchRemotePosts() async {
    throw StateError('fetchRemote tidak boleh dipanggil saat test offline');
  }
}

void main() {
  test('PostsNotifier mengembalikan cache saat forceOffline = true', () async {
    final fake = FakePostRepository(
      cached: const [
        Post(id: 1, userId: 1, title: 'Cached', body: 'dari lokal'),
      ],
    );

    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        postRepositoryProvider.overrideWithValue(fake),
        forceOfflineProvider.overrideWith(() {
          final n = ForceOfflineNotifier();
          return n;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(forceOfflineProvider.notifier).set(true);

    final posts = await container.read(postsProvider.future);
    expect(posts, hasLength(1));
    expect(posts.first.title, 'Cached');
  });

  test(
    'PostsNotifier melempar OfflineException saat offline + cache kosong',
    () async {
      final fake = FakePostRepository(cached: const []);

      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          postRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      container.read(forceOfflineProvider.notifier).set(true);

      await expectLater(
        container.read(postsProvider.future),
        throwsA(isA<OfflineException>()),
      );
    },
  );
}
