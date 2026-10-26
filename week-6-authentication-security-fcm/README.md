# Campus LMS — Minggu 6 Authentication, Security & FCM

Laksamana AryaPutra, 244107020021, TI-3C.

Project LMS kampus untuk praktikum minggu 6. Ada login (masih mock), token disimpan aman, dan Firebase Cloud Messaging.

## Fitur

- Login dulu baru bisa masuk LMS
- Token access/refresh lewat `flutter_secure_storage`, bukan SharedPreferences
- Kalau request API kena 401, app coba refresh sekali. Kalau tetap gagal, logout
- Notifikasi: minta izin, ambil token (di Profil cuma 12 karakter), langganan topik `pengumuman-kampus`
- Kalau app lagi kebuka, banner pakai `flutter_local_notifications`
- Ketuk notifikasi bisa ke halaman pengumuman

Stack: Flutter, Riverpod, GoRouter, Dio, flutter_secure_storage, firebase_core, firebase_messaging, flutter_local_notifications.

## Cara run

```
flutter pub get
flutter run
```

Pakai HP asli atau emulator yang ada Google Play. Login pakai email yang ada `@`, password minimal 6 karakter (contoh `mahasiswa@jti.polinema.ac.id`).

Kirim notifikasi dari Firebase Console → Messaging → Notifications. Jangan In-App Messaging, itu beda. Target topiknya `pengumuman-kampus`. Di tab Profil ada juga tombol Uji notifikasi lokal.

Backend kampus `POST /devices` belum ada, jadi token FCM tidak saya kirim ke `example-campus-api.test`. Itu cuma mock.

Tes otomatis: `flutter analyze lib test` dan `flutter test`.

## AI Verification Checklist

Saya cek draf AI ke kode di `lib/messaging/push_service.dart`.

1. Background handler top-level + `@pragma('vm:entry-point')`?

Iya. `firebaseMessagingBackgroundHandler` fungsi biasa di luar class, ada pragma-nya. Bukan method di dalam class. Isolate background juga tidak nyentuh BuildContext.

2. `onTokenRefresh` beneran kirim token baru ke backend, bukan cuma di-log?

Tidak. Listener-nya ada, tapi isinya cuma update preview 12 karakter di Profil. `POST /devices` saya skip karena endpoint kampus belum ada. Token penuh juga tidak saya print. Kalau dikirim ke URL mock, seolah-olah backend-nya sudah jadi, padahal tidak.

Nanti kalau API kampusnya sudah ada, tinggal isi `_syncToken` dengan `POST /devices`. Token ditaruh di body, jangan di URL.

3. Foreground pakai local notification manual?

Iya. `onMessage` panggil `_local.show`. Kalau tidak gitu, banner tidak muncul pas app masih kebuka. Sudah saya tes 26 Oktober 2026: pesan Hello from Polinema / Tes notification muncul di Beranda.

4. Klik dari tiga state (foreground, background, terminated) masuk ke rute yang benar?

Handler-nya saya pasang, tapi belum saya buktikan semuanya. Rute diambil dari `data.route`.

- Foreground: banner dari Console kelihatan pas app kebuka. Ketuk ke halaman pengumuman saya coba lewat tombol uji lokal (`/pengumuman/lokal`).
- Background: kodenya ada (`onMessageOpenedApp`), campaign di Console Completed, tapi saya belum catat bukti ketuk dari status bar sampai ke rute tertentu.
- Terminated: `getInitialMessage` sudah ada, belum saya uji (app ditutup total, kirim, baru diketuk).

Tes Console kemarin isinya title/body aja. Biar kliknya ke halaman yang tepat, payload-nya perlu ada `data.route`, misalnya `/pengumuman/3`. Kalau tidak ada, parser-nya balik ke `/`.

5. Token/secret tidak di-hardcode dan tidak di-log penuh?

Untuk kode Dart, iya. Access/refresh cuma lewat TokenStore. Token FCM di UI dipotong. Tidak ada print token. `google-services.json` itu config klien Firebase, bukan refresh token user.

Boilerplate dari AI saya pakai: handler top-level, banner foreground, secure storage, refresh 401, subscribe topik. Yang tidak saya ikut: kirim token ke URL contoh, log token penuh, bilang tiga state sudah lulus padahal baru foreground yang ada bukti, In-App Messaging, dan nambah firebase-bom di Gradle. Yang dinilai yang beneran jalan di HP, bukan yang cuma kelihatan lengkap di kode.

## Error yang sering ketemu

- Token null di emulator: emulator tanpa Google Play. Pakai HP atau image yang ada Play Store.
- Banner tidak muncul pas app kebuka: sistem tidak nampilin otomatis. Harus `_local.show` di `onMessage`.
- Klik notifikasi tidak pindah halaman (app sudah mati): `getInitialMessage` harus dipanggil setelah router siap, teruskan `data.route`.
- 401 muter terus: interceptor retry sekali setelah refresh; kalau refresh gagal, `clear()` lalu ke `/login`.
- MissingPluginException: stop app, `flutter run` ulang. Jangan andalkan hot reload setelah nambah plugin.
- Notifikasi iOS tidak muncul: APNs belum di-setup. Praktikum ini jalan di Android.

## Checklist

- Token di `flutter_secure_storage`, bukan SharedPreferences / log / screenshot penuh.
- 401 refresh sekali lalu retry; refresh mati paksa login ulang.
- Foreground sudah ada bukti di HP. Background dan terminated handlernya ada, klik ke rute belum saya rekam lengkap.
- Topik untuk siaran, token perangkat untuk pesan personal.
- `flutter analyze` dan `flutter test`.
