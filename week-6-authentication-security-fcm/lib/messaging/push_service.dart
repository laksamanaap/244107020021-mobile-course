import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message_route.dart';

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
  static const _channelId = 'pengumuman';

  final ValueNotifier<FcmStatus> status = ValueNotifier(FcmStatus.idle);
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

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

    // Codelab + Firebase Console masih memakai FCM registration token.
    // firebase_messaging 17 menandai getToken/onTokenRefresh deprecated
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

  /// Banner uji tanpa Firebase Console — membuktikan local notification hidup.
  Future<void> showDemoNotification() async {
    if (!_localReady) {
      await _initLocalNotifications();
    }
    await _local.show(
      id: 9001,
      title: 'Uji notifikasi lokal',
      body: 'Ketuk banner ini untuk membuka pengumuman demo.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Pengumuman Kampus',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: '/pengumuman/lokal',
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
        _channelId,
        'Pengumuman Kampus',
        importance: Importance.high,
      ),
    );
    _localReady = true;
  }

  Future<void> _syncToken(String? token) async {
    if (token == null || token.isEmpty) {
      status.value = status.value.copyWith(
        tokenPreview: 'tidak tersedia',
        backendNote: 'Token FCM belum ada. Emulator tanpa Google Play sering gagal; pakai HP fisik.',
      );
      return;
    }
    status.value = status.value.copyWith(
      tokenPreview: _preview(token),
      backendNote:
          'POST /devices dilewati: backend kampus belum tersedia. '
          'Token tidak dikirim ke example-campus-api.test (mock).',
    );
  }

  Future<void> _onForeground(RemoteMessage message) async {
    const details = AndroidNotificationDetails(
      _channelId,
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: details),
      payload: routeFromMessage(message.data),
    );
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
      backendNote: 'Firebase gagal diinisialisasi. Cek google-services.json dan Google Play services.',
    );
  }
}
