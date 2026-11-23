# Campus LMS — Minggu 11 Optimasi Performa

Laksamana AryaPutra, 244107020021, TI-3C.

Project ini menyalin aplikasi LMS minggu autentikasi, lalu diubah namanya dan dioptimasi sesuai codelab Minggu 11. Login Sanctum, token di secure storage, dan FCM tetap ada. Yang ditambah minggu ini: widget yang tidak perlu di-rebuild, daftar yang malas, gambar yang didekode seukuran tile, dan cache notifikasi.

## Cara menjalankan

```
flutter pub get
flutter analyze
flutter test
flutter run
```

Akun percobaan di layar login: `mahasiswa@jti.polinema.ac.id` / `password` (mock kalau tidak disambungkan ke API). Backend Laravel, kalau dipakai, tetap `php artisan serve --host=0.0.0.0 --port=8000`.

`flutter analyze` di mesin ini: 0 error. Ada 6 info lama (API FCM yang deprecated, `print` di `Mahasiswa`, dan anotasi tipe pada constructor). `flutter test`: 25 lulus.

## Yang diubah untuk performa

Catatan lengkap ada di `docs/performance-findings.md` dan `docs/performance-report.md`.

- Filter beranda punya state sendiri. Grid gambar tidak ikut terbangun saat chip diganti.
- Tab Kursus memakai `ListView.builder` dan pagination.
- `LmsCover` mengisi `cacheWidth` / `cacheHeight`. URL memakai `CachedNetworkImage` plus `memCacheWidth`.
- Notifikasi API memakai cache stale-while-revalidate.
- Tema Poppins dibuat sekali. Cache gambar dibatasi. `MapController` di-dispose.
- GET yang putus koneksinya dicoba ulang, 401 tetap ditangani interceptor yang lama.

## Firebase

`applicationId` Android sekarang `com.example.week11_perfomance_optimization`. Entri `package_name` di `google-services.json` disamakan supaya plugin Google Services tidak menolak build. App Firebase di console masih terdaftar untuk paket lama, jadi push belum masuk sampai app Android baru didaftarkan dan `google-services.json` diunduh ulang.
