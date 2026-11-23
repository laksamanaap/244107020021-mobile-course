# Laporan optimasi

## Baseline

| Ukuran | Sebelum | Sesudah |
| --- | --- | --- |
| Tile yang terpasang untuk 80 item | 80 (`Column`) | 11 (`ListView.builder`) |
| Waktu `pump` di widget test | 129592 µs | 74253 µs |
| Rebuild grid saat filter diganti | ikut `setState` induk | tetap 1 |
| Rebuild daftar "Lanjutkan belajar" | ikut induk | 1 menjadi 2 (memang harus berubah) |

Angka dari `flutter test` pada `test/performance_opt_test.dart`, bukan dari HP. Overlay performa di tangkapan layar menampilkan `0.0 ms/frame` karena binding tes tidak menghasilkan frame perangkat sungguhan. Overlay itu hanya bukti widget-nya terpasang.

## Optimasi yang dipakai

1. **Const dan widget terpisah.** Chip filter, judul seksi, dan grid akses cepat class sendiri. Filter memakai `ChangeNotifier` lewat `InheritedNotifier`, jadi hanya chip dan daftar yang bergantung yang rebuild.
2. **`ListView.builder` dan pagination.** Tab Kursus memuat 6 item per halaman, item berikutnya saat scroll mendekati 200 px dari bawah. Indikator loading ada di akhir daftar.
3. **Gambar.** `LmsCover` set `cacheWidth`/`cacheHeight` dari lebar logis kali device pixel ratio. Kalau ada URL, `CachedNetworkImage` memakai `memCacheWidth`. Tile dibungkus `RepaintBoundary`.
4. **Riverpod `select`.** Layar login hanya mengawasi `isLoading` dan `error`, bukan seluruh `AsyncValue`.
5. **Cache repositori.** `NotificationRepository.load` mengembalikan cache dulu, lalu mengambil data baru. Kalau fetch gagal dan cache ada, cache yang dikembalikan.
6. **Memori.** `ScrollController` pagination di-`dispose` dan listener-nya dilepas. `MapController` peta ikut di-`dispose`. `imageCache` dibatasi 80 gambar atau 40 MB. `ThemeData` Poppins disimpan di state, tidak dibuat tiap `build`.
7. **Jaringan.** GET yang gagal karena timeout atau koneksi dicoba ulang maksimal dua kali. Respons 401 tidak masuk jalur ini.

`compute` / isolate tidak dipakai. Daftar lokal 24 baris dan JSON notifikasi kecil. Memindahkannya ke isolate menambah salinan data tanpa beban yang kelihatan.

## Verifikasi

- `flutter test`: 25 lulus, termasuk hitungan rebuild, halaman katalog, cache notifikasi, dan jumlah tile.
- `flutter analyze`: 0 error.
- `flutter build web`: berhasil.
- `flutter build apk`: tidak dijalankan, Android SDK tidak terpasang.

## Pertanyaan codelab

Dampak paling jelas ada pada daftar. 80 tile turun menjadi 11 yang terpasang, dan waktu pump di tes turun dari sekitar 130 ms ke 74 ms. Filter yang tidak ikut membangun grid gambar dampaknya terasa saat mengetuk chip, karena gambar tidak di-decode ulang.

Verifikasi memakai penghitung build dan jumlah widget di pohon, bukan perasaan. Overlay 0.0 ms tidak saya pakai sebagai bukti kecepatan.

Trade-off: file UI lebih banyak class, pagination punya state halaman, cache bisa menampilkan notifikasi basi sesaat, dan `cached_network_image` menambah dependency. Satu item katalog punya URL gambar; kalau jaringan gagal, tile jatuh ke aset lokal.

Optimasi prematur saya hindari pada halaman yang isinya sedikit dan pada `compute` untuk JSON kecil. Codelab sendiri minta profil dulu, baru memperbaiki yang kelihatan mahal.
