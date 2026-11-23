import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/messaging/push_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/token_store.dart';
import 'domain/services/inbox_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

const showPerfOverlay = bool.fromEnvironment('SHOW_PERF_OVERLAY');

void configureImageCache() {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 80;
  cache.maximumSizeBytes = 40 * 1024 * 1024;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureImageCache();
  await bootstrapFirebaseAndPush();

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (_) {
    cameras = [];
  }

  runApp(MyAppWeek11(cameras: cameras));
}

class MyAppWeek11 extends StatelessWidget {
  const MyAppWeek11({
    super.key,
    this.cameras = const [],
    this.tokenStore,
    this.showPerformanceOverlay = showPerfOverlay,
  });

  final List<CameraDescription> cameras;
  final TokenStore? tokenStore;
  final bool showPerformanceOverlay;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        camerasProvider.overrideWithValue(cameras),
        if (tokenStore != null)
          tokenStoreProvider.overrideWithValue(tokenStore!)
        else
          authRepositoryProvider.overrideWith((ref) {
            return AuthRepositoryImpl(dio: ref.watch(apiClientProvider));
          }),
      ],
      child: _CampusApp(showPerformanceOverlay: showPerformanceOverlay),
    );
  }
}

class _CampusApp extends ConsumerStatefulWidget {
  const _CampusApp({required this.showPerformanceOverlay});

  final bool showPerformanceOverlay;

  @override
  ConsumerState<_CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<_CampusApp> {
  ThemeData? _theme;

  ThemeData _campusTheme() {
    return _theme ??= ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTheme.bg,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.brand,
        brightness: Brightness.light,
        primary: AppTheme.brand,
      ),
      dividerColor: AppTheme.hairline,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushService.instance.bindRouter((route) {
        ref.read(routerProvider).go(route);
      });
      InboxService.instance.persistCreate = (item) async {
        final created = await ref
            .read(campusApiProvider)
            .createNotification(
              type: 'list',
              title: item.title,
              body: item.body,
              route: item.route,
            );
        return (created['id'] as num?)?.toInt();
      };
      InboxService.instance.persistRead = (item) async {
        final id = item.serverId;
        if (id == null) return;
        await ref.read(campusApiProvider).markNotificationRead(id);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      title: 'Campus LMS',
      theme: _campusTheme(),
      routerConfig: router,
    );
  }
}
