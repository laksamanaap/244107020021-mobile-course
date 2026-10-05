import '../remote/post.dart';
import 'post_repository.dart';

/// Cache posts di memori — dipakai di Flutter Web.
class MemoryPostRepository extends PostRepository {
  MemoryPostRepository({super.dio, bool seedCache = false})
      : super(openDb: () => throw UnimplementedError('web')) {
    if (seedCache) {
      _cached = const [
        Post(
          id: 1,
          userId: 1,
          title: 'sunt aut facere repellat provident',
          body: 'quia et suscipit suscipit recusandae consequuntur',
        ),
        Post(
          id: 2,
          userId: 1,
          title: 'qui est esse',
          body: 'est rerum tempore vitae sequi sint nihil',
        ),
      ];
    }
  }

  List<Post> _cached = [];

  @override
  Future<List<Post>> getCachedPosts() async => List.from(_cached);

  @override
  Future<void> cachePosts(List<Post> posts) async {
    _cached = List.from(posts);
  }
}
