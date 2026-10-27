# Campus LMS — Minggu 6 Authentication, Security & FCM

Laksamana AryaPutra, 244107020021, TI-3C.

Project LMS kampus untuk praktikum minggu 6. Login ke API Laravel Sanctum, token disimpan aman, dan tiga tipe notifikasi FCM.

## Fitur

- Login ke `POST /api/login` (Laravel Sanctum), sesi dicek lewat `GET /api/me`
- Token access lewat `flutter_secure_storage`, bukan SharedPreferences
- HTTP 401 di endpoint terlindungi → logout (Sanctum tidak pakai refresh JWT)
- Notifikasi: minta izin, ambil token (di Profil cuma 12 karakter), langganan topik `pengumuman-kampus`
- Tiga tipe dari FCM `data.type`: `list` (kotak masuk, hilang saat dibaca), `icon` (status bar tanpa suara), `sound` (heads-up + bunyi)
- Kalau app lagi kebuka, banner pakai `flutter_local_notifications` sesuai channel
- Ketuk notifikasi bisa ke halaman pengumuman / kotak masuk

Stack: Flutter, Riverpod, GoRouter, Dio, flutter_secure_storage, firebase_core, firebase_messaging, flutter_local_notifications. Backend: Laravel + Sanctum di `week5-flutter-api-laravel`.

## Cara run

Backend (folder Laravel, laptop):

```
php artisan serve --host=0.0.0.0 --port=8000
```

Akun seeder: `mahasiswa@jti.polinema.ac.id` / `password`.

Flutter:

```
flutter pub get
flutter run
```

Pakai HP fisik (satu Wi-Fi dengan laptop). Base URL ada di `lib/data/api_config.dart` — ganti IP kalau `ipconfig` berubah. Jangan `localhost` dari HP.

Kirim notifikasi dari Firebase Console → Messaging → Notifications (bukan In-App Messaging). Target topik: `pengumuman-kampus`. Additional options:

```
type: list
route: /pengumuman/3
```

Ganti `type` jadi `icon` atau `sound`. Channel Android di Console: `notif_list` / `notif_icon` / `notif_sound`.

Di tab Profil ada tiga tombol cadangan uji lokal kalau Console lambat. Yang dinilai tetap kiriman FCM.

Tes otomatis: `flutter analyze lib test` dan `flutter test`.

## AI Verification Checklist

Saya cek draf AI ke kode di `lib/messaging/push_service.dart`.

1. Background handler top-level + `@pragma('vm:entry-point')`?

Iya. `firebaseMessagingBackgroundHandler` fungsi biasa di luar class, ada pragma-nya. Bukan method di dalam class. Isolate background juga tidak nyentuh BuildContext.

2. `onTokenRefresh` beneran kirim token baru ke backend, bukan cuma di-log?

Tidak ke `POST /devices` (endpoint itu tidak ada). Listener-nya ada, isinya update preview 12 karakter di Profil. Token penuh tidak di-print. Topik `pengumuman-kampus` yang dipakai siaran.

3. Foreground pakai local notification manual?

Iya. `onMessage` panggil `_local.show` ke channel sesuai `data.type`. Kalau tidak gitu, banner tidak muncul pas app masih kebuka.

4. Klik dari tiga state (foreground, background, terminated) masuk ke rute yang benar?

Handler-nya dipasang. Rute diambil dari `data.route`, kecuali `type=list` yang ke `/notifications`.

5. Token/secret tidak di-hardcode dan tidak di-log penuh?

Access token cuma lewat TokenStore. Token FCM di UI dipotong. Tidak ada print token. Password seeder memang diketahui untuk praktikum (`password`).

## Error yang sering ketemu

- Login gagal / timeout: HP tidak satu Wi-Fi, IP di `api_config.dart` salah, atau `artisan serve` tidak `--host=0.0.0.0`.
- Cleartext blocked: sudah diizinkan lewat `usesCleartextTraffic` + `network_security_config.xml`.
- Token null di emulator: emulator tanpa Google Play. Pakai HP.
- Banner tidak muncul pas app kebuka: harus `_local.show` di `onMessage`.
- Tipe salah: Console harus isi `data.type`, dan channel Android harus sama dengan yang dibuat di `push_service.dart`.
- MissingPluginException: stop app, `flutter run` ulang.

## Checklist

- Token di `flutter_secure_storage`, bukan SharedPreferences / log / screenshot penuh.
- Login sungguhan ke Laravel, `GET /api/me` untuk sesi.
- Tiga tipe FCM: list, icon, sound.
- Foreground pakai local notification sebagai layer tampilan, sumbernya tetap FCM.
- `flutter analyze` dan `flutter test`.
