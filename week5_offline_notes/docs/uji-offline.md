# Panduan Uji Offline — Week 5 Offline Notes

## (a) Tujuan

Memastikan aplikasi catatan offline-first berperilaku benar saat online, offline (mode pesawat / saklar **Paksa mode offline**), serta saat dirty flag dan cache-first posts dijalankan.

## (b) Prasyarat

- Emulator **Android** atau perangkat fisik (bukan Chrome / Flutter Web — sqflite tidak didukung di web).
- `flutter pub get` sudah dijalankan.
- Aplikasi dijalankan dengan `flutter run` (bukan hot-restart setelah menambah plugin baru tanpa stop).

## (c) Tabel uji Praktikum 4 — Offline-First (6 skenario)

| No | Skenario | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|---|
| 1 | Isi cache | Buka **Posts** saat online | Daftar posts dari JSONPlaceholder muncul dan tersimpan ke `cached_posts` | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 2 | Cache saat offline | Aktifkan **Paksa mode offline**, buka Posts lagi | Posts tetap tampil dari cache lokal | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 3 | Antrean dirty | Tambah/ubah catatan, lihat badge AppBar | Ikon awan oranye + angka dirty bertambah | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 4 | Sync ditolak | Aktifkan force offline, tekan **Sinkronkan** | Snackbar menolak sync (`OfflineException`) | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 5 | Sync berhasil | Matikan force offline, tekan **Sinkronkan** | Snackbar sukses, badge dirty hilang / ikon hijau | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 6 | Refresh background | Online + cache ada, buka Posts | UI langsung tampil cache; data bisa diperbarui di background | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |

## (d) Tabel uji Praktikum 3 — Halaman catatan (7 skenario)

| No | Skenario | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|---|
| 1 | Empty state | Buka app tanpa data / hapus semua | Teks "Belum ada catatan. Tekan + untuk menambah." | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 2 | Validasi form | Tekan +, biarkan judul kosong, simpan | Error "Judul wajib diisi" | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 3 | Tambah catatan | Isi judul+isi, simpan | Muncul di daftar, dirty chip/badge aktif | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 4 | Ubah via detail | Tap catatan → detail → ubah | Judul/isi berubah, dirty aktif | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 5 | Hapus | Tekan ikon hapus | Item hilang dari daftar | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 6 | Error state | (dev) paksa `fetchNotes` gagal | Pesan error + tombol "Coba lagi" | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |
| 7 | Mode pesawat | Airplane mode ON, buka daftar catatan | Daftar tetap bisa dibaca/ditulis (SQLite lokal) | ⏳ isi setelah uji manual | ⏳ isi setelah uji manual |

## (e) Mode pesawat di emulator Android

1. Buka Extended Controls emulator (tombol `...`) → **Battery** / **Cellular**, atau gunakan shortcut toolbar.
2. Alternatif: Settings perangkat emulator → Network & internet → Airplane mode.
3. Untuk demo kelas tanpa mengubah radio: gunakan saklar **Paksa mode offline** di halaman Pengaturan.

## (f) Hasil flutter analyze & flutter test

```
Analyzing week5_offline_notes...
No issues found! (ran in 3.3s)
```

```
00:00 +10: All tests passed!
```

(Flutter 3.47.2, Dart 3.13.2 — dijalankan 5 Oktober 2026)

## (g) Yang perlu di-screenshot (tempel langsung di README)

Tidak perlu nama file khusus. Ambil layar → tempel di slot README yang sesuai.

| Urutan | Di mana di app | Apa yang terlihat | Slot di README |
|---|---|---|---|
| 1 | **Pengaturan** (⚙) | Mode gelap OFF | Praktikum 1 — tema terang |
| 2 | **Pengaturan** | Mode gelap ON | Praktikum 1 — tema gelap |
| 3 | **Pengaturan** | Baris "Terakhir dibuka" | Praktikum 1 — terakhir dibuka |
| 4 | Terminal | `flutter analyze` OK | Praktikum 2 |
| 5 | **Catatan Offline** | Empty: "Belum ada catatan…" | Praktikum 3 |
| 6 | Dialog **+** | Error "Judul wajib diisi" | Praktikum 3 |
| 7 | **Catatan Offline** | Ada daftar + chip dirty | Praktikum 3 |
| 8 | **Catatan Offline** | Error + "Coba lagi" | Praktikum 3 |
| 9 | **Catatan Offline** + airplane | Daftar tetap jalan | Praktikum 3 |
| 10 | **Catatan Offline** | Badge awan oranye | Praktikum 4 — dirty sebelum |
| 11 | Home → Sinkronkan (offline ON) | Snackbar ditolak | Praktikum 4 |
| 12 | Home → Sinkronkan (offline OFF) | Snackbar berhasil | Praktikum 4 |
| 13 | **Catatan Offline** | Ikon hijau setelah sync | Praktikum 4 |
| 14 | **Posts** online | Daftar posts | Praktikum 4 |
| 15 | **Posts** + force offline | Masih dari cache | Praktikum 4 |
| 16 | Terminal | `flutter test` lulus | Praktikum 5 |
| 17 | **Catatan Offline** | Chip "belum tersinkron" | Refactoring |
| 18 | **Detail catatan** (tap item) | Halaman detail | Refactoring |

### Alur klik

Home → **+** / daftar / **Sinkronkan** → tap item (detail) → **Posts** → ⚙ **Pengaturan**
