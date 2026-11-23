# Temuan performa

Mesin praktikum ini tidak punya Android SDK dan tidak ada HP, jadi baseline bukan flame chart DevTools dari `flutter run --profile`. Yang saya lakukan: baca kode yang dipakai saat scroll dan ganti tab, lalu ukur ulang dengan widget test yang meniru pola lama dan pola baru.

## 1. Rebuild yang ikut ke gambar

`SpotifyHomePage` dulu satu `State`. Ketuk chip Semua / Kelas / Tugas memanggil `setState`, sehingga grid gambar, daftar, dan kartu kelas ikut dibangun lagi. Chip itu sebelumnya juga tidak menyaring isi.

## 2. Daftar yang menyiapkan semua anak

Tab Kursus memakai `ListView` pendek, tetapi polanya sama dengan `ListView(children: ...)`: item disiapkan sekaligus. Di tes, `Column` berisi 80 `ListTile` memasang 80 tile. `ListView.builder` untuk 80 item hanya memasang 11 tile yang masuk viewport.

## 3. Gambar didekode ukuran penuh

Tile 48–72 px memakai `Image.asset` tanpa `cacheWidth`. File JPG aslinya jauh lebih besar dari kotak di layar, jadi bitmap di memori ikut besar. Tidak ada batas `imageCache`.

## 4. Notifikasi selalu menunggu jaringan

`_hydrateInbox` langsung `GET /api/notifications`. Tidak ada salinan lokal. Kalau jaringan lambat, kotak masuk kosong sampai respons datang. Kalau gagal, tidak ada data terakhir.

## 5. Controller peta

`LocationMapPage` membatalkan stream GPS, tetapi `MapController` tidak di-`dispose`.

Yang tidak saya anggap masalah: halaman pengumuman cuma beberapa widget statis. Memecahnya atau memindahkan parse JSON kecil ke `compute` tidak ada beban yang terukur.
