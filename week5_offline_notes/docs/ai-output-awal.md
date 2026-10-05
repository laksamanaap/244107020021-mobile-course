# AI Output Awal (mentah)

Jawaban langsung terhadap prompt AI Prompt Challenge — belum dipoles.

## Perbandingan cepat

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
|---|---|---|---|---|
| Kompleksitas query | Hampir tidak ada query; key-value saja. Filter/urut harus di memori setelah baca seluruh JSON. | Query terbatas (key / box filter sederhana). Urut & join manual. | SQL penuh: WHERE, ORDER BY, INDEX, JOIN. Cocok 1000+ baris. | SQL typed + codegen; query kompleks tetap nyaman. |
| Relasi | Tidak ada. | Tidak native; box terpisah + id manual. | Relasi via foreign key / join SQL. | Relasi first-class di tabel Drift. |
| Reaktivitas / stream | Tidak ada stream bawaan; biasanya dibaca sekali + invalidate provider. | `box.watch()` / `ValueListenable` ada. | Tidak ada stream bawaan; perlu polling atau invalidate Riverpod. | `watch()` / stream query built-in — klaim "reaktif" paling kuat. |
| Type-safety | Lemah (String/bool/int/List<String>). Model sendiri. | Cukuk dengan TypeAdapter; error runtime jika adapter salah. | Map `String, Object?` — type-safety di lapisan model (`Note.fromMap`). | Sangat kuat: class tabel digenerate, compile-time check. |
| Boilerplate | Paling sedikit untuk preferensi. | Adapter + init Hive. Sedang. | Sedang: openDatabase, SQL string, repository. | Tinggi: drift_dev, build_runner, migrasi versi tabel. |
| Kemudahan testing | Mudah dengan mock SharedPreferences / fake repo. | Perlu path temporary / mock box. | DI `openDb` + fake repo (seperti praktikum ini) sangat enak. | Bisa in-memory SQLite; setup codegen di test lebih berat. |

## Rekomendasi final (output awal)

| Kebutuhan | Pilihan | Alasan singkat |
|---|---|---|
| Preferensi (tema, last opened) | SharedPreferences | Key-value kecil, API sederhana, sudah cukup. |
| Daftar catatan offline-first | **Hive** | Cepat, API box mudah, ada watch. Dirty flag bisa field di object. |

Skema box catatan (usulan awal AI):

```
notesBox:
  id: int
  title: String
  content: String
  dirty: bool
  updatedAt: DateTime
```

Trade-off yang disebut AI: Hive lebih "Flutter-native" daripada menulis SQL; untuk 1000 catatan masih ringan di memori. sqflite lebih baik kalau nanti butuh query berat / join posts. Drift overkill untuk modul ini.

## Catatan

Output ini sengaja menyimpan rekomendasi Hive untuk catatan agar tahap verifikasi punya sesuatu yang bisa dikoreksi (lihat checklist di `perbandingan-storage.md`).
