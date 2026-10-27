import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';
import 'inbox_service.dart';
import 'notif_kind.dart';

/// Handler background WAJIB top-level + pragma. Jangan akses BuildContext,
/// GoRouter, atau Riverpod di sini (isolate terpisah).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

class FcmStatus {
  const FcmStatus({
    required this.ready,
    required this.permissionLabel,
    required this.tokenPreview,
    required this.topicLabel,
    required this.backendNote,
  });

  final bool ready;
  final String permissionLabel;
  final String tokenPreview;
  final String topicLabel;
  final String backendNote;

  static const idle = FcmStatus(
    ready: false,
    permissionLabel: 'belum diinisialisasi',
    tokenPreview: '—',
    topicLabel: '—',
    backendNote:
        'FCM aktif di Android/iOS setelah Firebase.initializeApp() di main().',
  );

  FcmStatus copyWith({
    bool? ready,
    String? permissionLabel,
    String? tokenPreview,
    String? topicLabel,
    String? backendNote,
  }) {
    return FcmStatus(
      ready: ready ?? this.ready,
      permissionLabel: permissionLabel ?? this.permissionLabel,
      tokenPreview: tokenPreview ?? this.tokenPreview,
      topicLabel: topicLabel ?? this.topicLabel,
      backendNote: backendNote ?? this.backendNote,
    );
  }
}

/// Lifecycle FCM: izin, token, refresh, topik, banner foreground.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const topicKampus = 'pengumuman-kampus';
  static const channelList = 'notif_list';
  static const channelIcon = 'notif_icon';
  static const channelSound = 'notif_sound_jokowi';
  static const _jokowiSound = RawResourceAndroidNotificationSound(
    'hidupjokowi',
  );
  static const _appIcon = DrawableResourceAndroidBitmap('ic_launcher');

  final ValueNotifier<FcmStatus> status = ValueNotifier(FcmStatus.idle);
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _sfx = AudioPlayer();

  bool _initialized = false;
  bool _localReady = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  void Function(String route)? _go;
  String? _pendingRoute;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();

    final allowed = await requestNotificationPermission();
    final permissionLabel = PushService.instance.status.value.permissionLabel;

    if (!allowed) {
      status.value = FcmStatus(
        ready: false,
        permissionLabel: permissionLabel,
        tokenPreview: '—',
        topicLabel: 'dilewati (izin ditolak)',
        backendNote:
            'Izin notifikasi ditolak. Aplikasi tetap jalan tanpa crash. '
            'Android 13+ memakai POST_NOTIFICATIONS; iOS butuh dialog + APNs.',
      );
      return;
    }

    await _syncToken(await FirebaseMessaging.instance.getToken());
    _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(
      _syncToken,
    );

    var topicLabel = 'gagal berlangganan $topicKampus';
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topicKampus);
      topicLabel = 'berlangganan $topicKampus';
    } catch (_) {
      topicLabel = 'gagal berlangganan $topicKampus';
    }

    _foregroundSub ??= FirebaseMessaging.onMessage.listen(_onForeground);
    _openedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _openFromMessage,
    );

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _openFromMessage(initial);
    }

    status.value = status.value.copyWith(ready: true, topicLabel: topicLabel);
  }

  /// Android 13+ / iOS: dialog runtime. Denied tidak boleh crash.
  Future<bool> requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    final allowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    status.value = status.value.copyWith(
      permissionLabel: settings.authorizationStatus.name,
    );
    return allowed;
  }

  void bindRouter(void Function(String route) go) {
    _go = go;
    final pending = _pendingRoute;
    _pendingRoute = null;
    if (pending != null && pending.isNotEmpty) {
      go(pending);
    }
  }

  /// Cadangan kelas kalau Firebase Console lambat. Sumber utama tetap FCM.
  Future<void> showDemoNotification({NotifKind kind = NotifKind.sound}) async {
    if (!_localReady) {
      await _initLocalNotifications();
    }
    const titles = {
      NotifKind.list: 'Uji list — kotak masuk',
      NotifKind.icon: 'Uji ikon status bar',
      NotifKind.sound: 'Uji notifikasi bersuara',
    };
    const bodies = {
      NotifKind.list: 'Buka lonceng. Ketuk item ini supaya hilang.',
      NotifKind.icon: 'Tanpa suara. Cek ikon di status bar.',
      NotifKind.sound: 'Heads-up plus Hidup Jokowi. Ketuk untuk buka pengumuman.',
    };
    await _present(
      id: 9000 + kind.index,
      title: titles[kind]!,
      body: bodies[kind]!,
      kind: kind,
      route: kind == NotifKind.list
          ? AppRoutes.notifications
          : AppRoutes.pengumumanId('lokal'),
    );
  }

  void _openRoute(String route) {
    if (_go == null) {
      _pendingRoute = route;
      return;
    }
    _go!(route);
  }

  Future<void> _initLocalNotifications() async {
    if (_localReady) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _openRoute(payload);
        }
      },
    );

    final launch = await _local.getNotificationAppLaunchDetails();
    final launchPayload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      _openRoute(launchPayload);
    }

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelList,
        'Kotak masuk',
        description: 'Pengumuman yang masuk daftar in-app',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIcon,
        'Ikon status bar',
        description: 'Ikon di status bar tanpa suara',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
    await androidPlugin?.deleteNotificationChannel(channelId: 'notif_sound');
    await androidPlugin?.deleteNotificationChannel(channelId: channelSound);
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelSound,
        'Pengumuman bersuara',
        description: 'Heads-up plus Hidup Jokowi',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: _jokowiSound,
        audioAttributesUsage: AudioAttributesUsage.media,
      ),
    );
    _localReady = true;
  }

  Future<void> _syncToken(String? token) async {
    if (token == null || token.isEmpty) {
      status.value = status.value.copyWith(
        tokenPreview: 'tidak tersedia',
        backendNote:
            'Token FCM belum ada. Emulator tanpa Google Play sering gagal; pakai HP fisik.',
      );
      return;
    }
    status.value = status.value.copyWith(
      tokenPreview: _preview(token),
      backendNote:
          'Langganan topik $topicKampus. Demo ke dosen: Firebase Console → '
          'Messaging → topic $topicKampus, isi data.type = list / icon / sound. '
          'Channel Android: $channelList / $channelIcon / $channelSound.',
    );
  }

  Future<void> _onForeground(RemoteMessage message) async {
    final kind = notifKindFromMessage(message.data);
    final title = message.notification?.title ?? 'Pengumuman';
    final body = message.notification?.body ?? '';
    await _present(
      id: message.hashCode,
      title: title,
      body: body,
      kind: kind,
      route: routeFromMessage(message.data),
    );
  }

  Future<void> _present({
    required int id,
    required String title,
    required String body,
    required NotifKind kind,
    required String route,
  }) async {
    if (kind == NotifKind.list) {
      await InboxService.instance.ingestList(
        title: title,
        body: body,
        route: route,
      );
    }
    if (kind == NotifKind.sound) {
      await _playJokowi();
    }
    await _local.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _detailsFor(kind),
      payload: route,
    );
  }

  NotificationDetails _detailsFor(NotifKind kind) {
    final android = switch (kind) {
      NotifKind.list => const AndroidNotificationDetails(
        channelList,
        'Kotak masuk',
        channelDescription: 'Pengumuman yang masuk daftar in-app',
        icon: '@mipmap/ic_launcher',
        largeIcon: _appIcon,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: false,
      ),
      NotifKind.icon => const AndroidNotificationDetails(
        channelIcon,
        'Ikon status bar',
        channelDescription: 'Ikon di status bar tanpa suara',
        icon: '@mipmap/ic_launcher',
        largeIcon: _appIcon,
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        silent: true,
        visibility: NotificationVisibility.secret,
      ),
      NotifKind.sound => const AndroidNotificationDetails(
        channelSound,
        'Pengumuman bersuara',
        channelDescription: 'Heads-up plus Hidup Jokowi',
        icon: '@mipmap/ic_launcher',
        largeIcon: _appIcon,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        sound: _jokowiSound,
        audioAttributesUsage: AudioAttributesUsage.media,
        category: AndroidNotificationCategory.message,
      ),
    };
    final ios = DarwinNotificationDetails(
      presentAlert: kind != NotifKind.icon,
      presentBadge: true,
      presentSound: kind == NotifKind.sound,
      sound: kind == NotifKind.sound ? 'hidupjokowi.mp3' : null,
    );
    return NotificationDetails(android: android, iOS: ios);
  }

  Future<void> _playJokowi() async {
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/hidupjokowi.mp3'), volume: 1);
    } catch (_) {}
  }

  void _openFromMessage(RemoteMessage message) {
    _openRoute(routeFromMessage(message.data));
  }

  /// 12 karakter pertama saja — jangan tampilkan / log token penuh.
  static String _preview(String token) {
    if (token.length <= 12) return '$token…';
    return '${token.substring(0, 12)}…';
  }
}

Future<void> bootstrapFirebaseAndPush() async {
  if (kIsWeb) return;
  try {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
  } catch (_) {
    return;
  }
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushService.instance.initialize();
  } catch (_) {
    PushService.instance.status.value = const FcmStatus(
      ready: false,
      permissionLabel: 'error',
      tokenPreview: '—',
      topicLabel: '—',
      backendNote:
          'Firebase gagal diinisialisasi. Cek google-services.json dan Google Play services.',
    );
  }
}
