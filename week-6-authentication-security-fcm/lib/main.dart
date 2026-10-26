import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'camera_home_page.dart';
import 'kelas_session.dart';
import 'lms_content.dart';
import 'location_map_page.dart';
import 'data/token_store.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'spotify_home_page.dart';

final camerasProvider = Provider<List<CameraDescription>>((ref) => const []);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) {
          return MusicPlayboxPage(cameras: ref.read(camerasProvider));
        },
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) {
          return AnnouncementPage(id: state.pathParameters['id'] ?? '');
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

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
          tokenStoreProvider.overrideWithValue(tokenStore!),
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

class MusicPlayboxPage extends StatefulWidget {
  const MusicPlayboxPage({super.key, this.cameras = const []});

  final List<CameraDescription> cameras;

  @override
  State<MusicPlayboxPage> createState() => _MusicPlayboxPageState();
}

class _MusicPlayboxPageState extends State<MusicPlayboxPage> {
  final ScrollController _controller = ScrollController();
  int _navIndex = 0;

  void _selectTab(int index) {
    setState(() => _navIndex = index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openBottomSheet(BuildContext context) {
    showSyllabusSheet(context: context, controller: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _navIndex == 0;
    final headerTitle = switch (_navIndex) {
      0 => _greetingText(),
      1 => 'Kelas',
      2 => 'Kursus',
      _ => 'Profil',
    };

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: null,
      endDrawer: _navIndex == 1 ? _buildQueueDrawer() : null,
      body: Column(
        children: [
          // Sticky — di luar scroll, tetap di atas
          AppStickyHeader(title: headerTitle, onAvatarTap: () => _selectTab(3)),
          Expanded(
            child: switch (_navIndex) {
              0 => SpotifyHomePage(onOpenPlaybox: () => _selectTab(1)),
              1 => _buildMusicPlayboxBody(),
              2 => _buildLibraryBody(),
              _ => _buildProfileBody(),
            },
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHome) SpotifyMiniPlayer(onTap: () => _selectTab(1)),
          BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: _selectTab,
            backgroundColor: AppTheme.headerBg,
            selectedItemColor: AppTheme.brand,
            unselectedItemColor: AppTheme.muted,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Kelas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Kursus',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sapaan mengikuti jam WIB (UTC+7).
  String _greetingText() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = wib.hour;
    // Pagi 04–10 | Siang 11–14 | Sore 15–17 | Malam 18–03
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _buildQueueDrawer() {
    return const KelasQueueDrawer();
  }

  Widget _buildMusicPlayboxBody() {
    return Builder(
      builder: (context) {
        return AppTheme.page(
          safeTop: false,
          child: KelasSessionBody(
            onOpenSyllabus: () => openBottomSheet(context),
            onOpenQueue: () => Scaffold.of(context).openEndDrawer(),
          ),
        );
      },
    );
  }

  Widget _buildLibraryBody() {
    final songs = [
      ('Pemrograman Mobile', 'TI-3C · 12 pertemuan', LmsImages.authFcm),
      ('Basis Data Lanjut', 'TI-3C · 10 pertemuan', LmsImages.basisData),
      ('Tugas terkumpul', '4 berkas', null),
      ('Jaringan Komputer', 'Praktikum · Lab JTI', LmsImages.quizSubnetting),
    ];

    return AppTheme.page(
      safeTop: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: songs.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 3,
                    height: 18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.brandSoft,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Mata kuliah kamu',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }
          final song = songs[index - 1];
          final image = song.$3;
          return Material(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              onTap: () => _selectTab(1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: image == null
                  ? Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [AppTheme.brand, AppTheme.brandSoft],
                        ),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
              title: Text(
                song.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                ),
              ),
              subtitle: Text(
                song.$2,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.brandSoft,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileBody() {
    return AppTheme.page(
      safeTop: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandSoft.withValues(alpha: 0.55),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.brand,
                child: Text(
                  'LA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Laksamana AryaPutra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '244107020021 · D4 Teknik Informatika · TI-3C',
              style: TextStyle(color: AppTheme.muted),
            ),
          ),
          const SizedBox(height: 28),

          const SizedBox(height: 14),
          _DemoLaunchCard(
            icon: Icons.badge_outlined,
            title: 'Absensi kamera',
            subtitle: 'Ambil foto kehadiran dan simpan ke galeri',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppTheme.bg,
                    appBar: AppTheme.appBar('Absensi kamera'),
                    body: CameraHomePage(cameras: widget.cameras),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DemoLaunchCard(
            icon: Icons.map_outlined,
            title: 'Peta kampus',
            subtitle: 'Lokasi kelas, Polinema, dan titik praktikum',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocationMapPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              return _DemoLaunchCard(
                icon: Icons.verified_user_outlined,
                title: 'Uji request terlindungi',
                subtitle: 'Simulasi 401, refresh token, lalu ulang sekali',
                onTap: () async {
                  try {
                    final data = await ref
                        .read(campusApiProvider)
                        .fetchProtected();
                    if (!context.mounted) return;
                    final ok = data['ok'] == true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Request lolos (mock). Header Bearer dipakai; 401 di-refresh sekali.'
                              : 'Request selesai tanpa ok=true.',
                        ),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Request gagal. Sesi dibersihkan jika refresh mati.',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<FcmStatus>(
            valueListenable: PushService.instance.status,
            builder: (context, fcm, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Cloud Messaging',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Izin: ${fcm.permissionLabel}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Token: ${fcm.tokenPreview}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Topik: ${fcm.topicLabel}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fcm.backendNote,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () async {
                          try {
                            await PushService.instance.showDemoNotification();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Banner lokal dikirim. Ketuk notifikasi untuk buka pengumuman.',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal menampilkan banner lokal. Cek izin notifikasi.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Uji notifikasi lokal'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brandDeep,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppTheme.hairline),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.brandSoft.withValues(alpha: 0.2),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semester gasal · Tahun akademik 2026/2027',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'JTI Polinema · Campus LMS · Minggu 6 Auth, Security & FCM',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoLaunchCard extends StatelessWidget {
  const _DemoLaunchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.brand.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.brandSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fade-in saat widget baru masuk tree (mis. buka tab Playbox).
class _FadeInOnMount extends StatefulWidget {
  const _FadeInOnMount({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<_FadeInOnMount> createState() => _FadeInOnMountState();
}

class _FadeInOnMountState extends State<_FadeInOnMount> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: widget.child,
    );
  }
}
