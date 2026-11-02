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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebaseAndPush();

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (_) {
    cameras = [];
  }

  runApp(MyAppWeek6(cameras: cameras));
}

class MyAppWeek6 extends StatelessWidget {
  const MyAppWeek6({super.key, this.cameras = const [], this.tokenStore});

  final List<CameraDescription> cameras;
  final TokenStore? tokenStore;

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
      child: const _CampusApp(),
    );
  }
}

class _CampusApp extends ConsumerStatefulWidget {
  const _CampusApp();

  @override
  ConsumerState<_CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<_CampusApp> {
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
      title: 'Campus LMS',
      theme: ThemeData(
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
      ),
      routerConfig: router,
    );
  }
}
