import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/routing/app_routes.dart';
import '../pages/announcement_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/notifications_page.dart';
import '../providers/auth_provider.dart';

final camerasProvider = Provider<List<CameraDescription>>((ref) => const []);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return MusicPlayboxPage(cameras: ref.read(camerasProvider));
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.pengumuman,
        builder: (context, state) {
          return AnnouncementPage(id: state.pathParameters['id'] ?? '');
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
