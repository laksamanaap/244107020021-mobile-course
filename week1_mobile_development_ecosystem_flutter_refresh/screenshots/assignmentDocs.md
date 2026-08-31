# Refleksi Week 1: Mobile Development Ecosystem & Flutter Refresh

## 1. Perbedaan hot reload dan hot restart?

**Hot reload** -> Fitur Flutter yang memungkinkan perubahan kode ditampilkan pada aplikasi tanpa menjalankan ulang aplikasi secara keseluruhan. State yang sedang berjalan biasanya tetap dipertahankan, sehingga cocok digunakan saat melakukan perubahan pada tampilan.

**Hot restart** -> Menjalankan kembali aplikasi dari awal dan menghapus state yang sedang berjalan. Proses ini masih lebih cepat dibandingkan menjalankan aplikasi dari awal secara manual dan biasanya digunakan ketika perubahan tidak dapat diterapkan dengan hot reload.

---

## 2. Kapan native lebih tepat dipilih daripada cross-platform?

Native (Swift/Kotlin langsung) lebih pas jika :

- Integrasi yang sangat spesifik dengan hardware atau fitur sistem operasi
- Performa tinggi dan respons real-time
- Akses terhadap API atau fitur terbaru yang belum tersedia pada framework cross-platform
- Pengembangan yang memang difokuskan pada satu platform tertentu

Cross-platform (Flutter, React Native) lebih masuk akal kalau mau satu codebase buat Android + iOS, tim kecil, atau MVP yang harus cepat jadi

---

## 3. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

Dalam Flutter, tampilan aplikasi dibangun menggunakan pendekatan UI deklaratif. Artinya, developer dapat mendefinisikan bagaimana tampilan seharusnya terlihat berdasarkan kondisi atau state yang dimiliki aplikasi

Alurnya secara sederhana :

1. Aplikasi memiliki state atau data
2. Widget tree mendeskripsikan tampilan berdasarkan state tersebut
3. Ketika state berubah, fluter melakukan proses rebuild pada state terdampak
4. Tampilan menyesuaikan state baru

Dengan alur diatas, developer tidak perlu mengubah elemen UI secara manual satu persatu, developer hanya perlu CTRL + S agar STATE UI Terbaru ter-refresh

---

## 4. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?

Commit yang kecil dan memiliki pesan yang jelas, membuat perubahan dalam sebuah project lebih mudah dipahami dan dilacak.

Untuk tim :

- Setiap commit memiliki perubahan yang lebih terfokus
- Perubahan yang menyebabkan masalah lebih mudah ditemukan
- Proses code review menjadi lebih sederhana
- Anggota dapat memahami perkembangan project tanpa harus cek semua kode

Untuk portfolio :

- Git history dapat menunjukan proses dan perkembangan projek
- Commit message yang jelas menunjukkan pekerjaan yang terstruktur
- Riwayat perubahan dapat menjadi dokumentasi mengenai fitur yang pernah dikerjakan
