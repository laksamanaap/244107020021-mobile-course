# Perbandingan Storage — Hasil Verifikasi

## AI Verification Checklist

1. **Apakah output awal menaruh daftar catatan di SharedPreferences?**  
   Tidak. Output awal merekomendasikan Hive untuk catatan, SharedPreferences hanya untuk preferensi → **sesuai** (tidak ditolak pada butir ini).

2. **Apakah skema mendukung antrean sync (`dirty`, `updated_at`) atau hanya CRUD polos?**  
   Output awal sudah menyertakan `dirty` dan `updatedAt` di skema box → **sesuai**.

3. **Apakah klaim "real-time/reaktif" didukung stream nyata?**  
   Output awal menyebut `box.watch()` (Hive) dan Drift `watch()` — klaim itu valid untuk Hive/Drift. Untuk **sqflite** yang dipakai project, reaktivitas berasal dari **invalidate Riverpod** (`NoteActions._refresh`), bukan stream SQL → **dikoreksi**: jangan menyamakan sqflite dengan "stream bawaan".

4. **Apakah estimasi boilerplate masuk akal?**  
   Diverifikasi dengan `flutter pub add hive hive_flutter drift drift_flutter dev:drift_dev dev:build_runner --dry-run` (**tanpa** mengubah `pubspec.yaml`): **Would change 54 dependencies.**  
   Drift + Hive menambah analyzer, build_runner, code generation, dan langkah migrasi. Dibanding sqflite yang sudah terpasang (cukup `openDatabase` + SQL), boilerplate Drift jelas lebih besar → estimasi "Drift tinggi / sqflite sedang" **sesuai**.

5. **Keputusan final + alasan**  
   Output awal merekomendasikan **Hive untuk catatan** → **ditolak / dikoreksi**.  
   Keputusan project (dan modul): **SharedPreferences untuk preferensi + sqflite untuk catatan**, karena butuh: dirty flag, `ORDER BY updated_at`, update parsial per baris, transaksi + batch (cache posts), dan testing dengan `FakeNoteRepository` via DI `openDb` tanpa code generation.

## Tabel lembar kerja (9 kriteria)

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
|---|---|---|---|---|
| Kompleksitas query | Sangat rendah (key-value) | Rendah–sedang | Tinggi (SQL penuh) | Tinggi tapi typed |
| Relasi antar data | Tidak | Manual | Ya (SQL join/FK) | Ya (model relasi) |
| Reaktivitas / stream | Tidak bawaan | `watch` / listenable | Tidak bawaan; lewat Riverpod | `watch` query |
| Type-safety | Lemah | Sedang (adapter) | Sedang (model Map) | Sangat kuat |
| Boilerplate | Sangat rendah | Sedang | Sedang | Tinggi (+54 paket dry-run) |
| Kemudahan testing | Mudah (fake/mock) | Sedang | Mudah dengan DI `openDb` | Sedang–sulit (codegen) |
| Cocok preferensi kecil | **Ya** | Bisa, overkill | Overkill | Overkill |
| Cocok 1000+ catatan + sync | Tidak | Bisa, query terbatas | **Ya** | Ya |
| Keputusan & alasan | Dipakai untuk tema & last opened | Ditolak untuk catatan di project ini | **Dipilih untuk notes + cached_posts** | Tidak dipilih (boilerplate) |

## Mengapa SharedPreferences + SQLite

Preferensi hanya beberapa key boolean/string — SharedPreferences cukup dan sudah terbukti di `PrefsRepository` / `DarkModeNotifier`. Catatan butuh antrean sync (`dirty`), urutan `updated_at DESC`, update satu baris, serta cache posts atomik (`transaction` + `batch` di `PostRepository`). sqflite memenuhi itu tanpa menambah puluhan paket codegen.

## Usulan skema 1000+ catatan (dokumentasi saja — skema app tetap version 1)

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL
);

-- usulan indeks (tidak diubah di onCreate aplikasi saat ini):
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
```
