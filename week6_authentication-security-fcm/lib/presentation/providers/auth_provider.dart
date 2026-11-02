import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';
import '../messaging/inbox_service.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

final apiClientProvider = Provider((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    onSessionExpired: () async {
      InboxService.instance.clear();
      ref.invalidate(authStateProvider);
    },
  );
});

final campusApiProvider = Provider<CampusApi>((ref) {
  return CampusApi(ref.watch(apiClientProvider));
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      final token = await ref.watch(tokenStoreProvider).readAccess();
      if (token == null || token.isEmpty) return false;
      await ref.read(authRepositoryProvider).me();
      await _hydrateInbox();
      return true;
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      InboxService.instance.clear();
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      await _hydrateInbox();
      return true;
    });
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    await ref.read(tokenStoreProvider).clear();
    InboxService.instance.clear();
    ref.invalidateSelf();
  }

  Future<void> _hydrateInbox() async {
    if (!ref.read(authRepositoryProvider).usesLiveApi) return;
    try {
      final rows = await ref.read(campusApiProvider).listNotifications();
      InboxService.instance.replace(
        rows.map(CampusInboxItem.fromApi).toList(),
      );
    } catch (_) {}
  }
}
