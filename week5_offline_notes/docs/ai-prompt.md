# AI Prompt Challenge — Week 5 Offline Notes

**Tool:** Cursor (Agent mode)  
**Tanggal:** 5 Oktober 2026  
**Project:** `week5_offline_notes`

## Prompt (dari modul)

> Bandingkan SharedPreferences, Hive, sqflite, dan Drift untuk aplikasi catatan offline-first dengan dirty flag dan sinkronisasi. Buat tabel perbandingan pada kriteria: kompleksitas query, dukungan relasi, reaktivitas/stream, type-safety, boilerplate, dan kemudahan testing. Rekomendasikan kombinasi storage untuk (a) preferensi pengguna dan (b) daftar catatan (≥1000 baris). Usulkan skema tabel/box termasuk field untuk antrean sync, serta trade-off keputusanmu.

## Konteks tambahan yang diberikan ke AI

- Aplikasi Flutter Riverpod, Android (bukan Web).
- Kebutuhan: dirty flag, `updated_at`, update parsial, transaksi, testing dengan repository palsu.
- Sudah terpasang: `shared_preferences`, `sqflite`, `path`, `dio`, `flutter_riverpod`.
