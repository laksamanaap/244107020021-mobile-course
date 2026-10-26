# MASTER PROMPT 01 — SELAMAT DATANG

## Flutter Minggu 6: Authentication, Security & FCM

### Konteks

Saya sedang mengerjakan codelab Minggu 6 dari JTI Politeknik Negeri Malang dengan topik Authentication, Security, dan Firebase Cloud Messaging (FCM).

Sumber materi resmi:
https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#0

Saya akan memberikan isi materi secara bertahap kepada kamu. Untuk saat ini, pelajari hanya bagian pembuka dan tujuan pembelajaran.

### Instruksi

Baca dan pahami materi yang saya berikan. Kemudian bantu saya memahami konteks praktikum sebelum mulai melakukan implementasi.

Jelaskan hal-hal berikut:

1. **Tujuan praktikum** — kemampuan yang harus saya kuasai setelah menyelesaikan codelab.
2. **Persiapan lingkungan** — perangkat lunak, perangkat pengujian, repository, dan akun yang diperlukan.
3. **Pengetahuan prasyarat** — relevansi Riverpod, AsyncValue, GoRouter, Dio, dan repository pattern.
4. **Gambaran materi** — hubungan autentikasi, keamanan token, FCM, dan penanganan notifikasi dalam satu aplikasi Flutter.
5. **Kebijakan penggunaan AI** — bagian yang boleh dibantu AI dan bagian yang wajib saya validasi sendiri.
6. **Checklist kesiapan** — hal-hal yang perlu saya pastikan sebelum masuk ke materi berikutnya.

### Aturan pengerjaan

- Gunakan bahasa Indonesia yang natural, jelas, dan mudah dipahami.
- Utamakan informasi dari materi resmi yang saya berikan.
- Jangan mengarang informasi yang tidak tersedia dalam materi.
- Jika ada istilah teknis, jelaskan secara singkat.
- Jangan menulis atau mengubah kode.
- Jangan menjalankan perintah terminal.
- Jangan membuat file atau folder.
- Jangan memasang package.
- Jangan mengonfigurasi Firebase.
- Jangan mulai mengimplementasikan fitur autentikasi atau FCM.
- Jangan membahas detail implementasi dari bagian selanjutnya.
- Jangan menganggap persiapan saya sudah selesai tanpa konfirmasi.
- Jangan melanjutkan ke materi berikutnya sebelum saya memberikan instruksi.

### Format jawaban

**A. Tujuan Pembelajaran**

**B. Persiapan**

**C. Pengetahuan Prasyarat**

**D. Gambaran Umum Arsitektur**

**E. Kebijakan Penggunaan AI**

**F. Checklist Kesiapan**

Gunakan penjelasan secukupnya. Fokus pada pemahaman saya, bukan pada panjangnya jawaban.

Setelah selesai, berhenti dan tunggu instruksi saya untuk materi berikutnya.

# MASTER PROMPT 02 — MODEL AUTENTIKASI

## Flutter Minggu 6: Authentication, Security & FCM

### Sumber Materi

https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#1

### Konteks

Saya sedang mengerjakan codelab Minggu 6 dari JTI Politeknik Negeri Malang. Pada tahap ini, fokus saya hanya pada bagian **“1. Model autentikasi yang dipakai di codelab ini”**.

Pelajari bagian tersebut dari sumber resmi di atas. Jangan mengerjakan bagian lain terlebih dahulu.

### Tujuan

Bantu saya memahami tiga pola autentikasi yang umum digunakan:

1. Firebase Authentication (email/Google).
2. JWT dengan access token dan refresh token pada REST API sendiri.
3. OAuth (Google Login).

Codelab ini menggunakan mock authentication provider dan JWT simulasi agar praktikum dapat berjalan tanpa backend sungguhan.

### Instruksi Pengerjaan

Jelaskan:

1. **Konsep autentikasi** — apa itu autentikasi dan mengapa aplikasi membutuhkannya.
2. **Tiga pola autentikasi** — cara kerja, komponen utama, kelebihan, kekurangan, dan skenario penggunaan.
3. **Perbedaan token** — fungsi ID token, access token, dan refresh token.
4. **Alur autentikasi** — dari pengguna melakukan login hingga aplikasi memperoleh token atau bukti autentikasi.
5. **Model dalam codelab** — fungsi mock authentication provider dan JWT simulasi serta perbedaannya dengan sistem autentikasi sungguhan.
6. **Repository pattern dan token refresh** — alasan pola ini tetap relevan saat sumber autentikasi diganti dengan Firebase Auth.
7. **Contoh penerapan** — berikan contoh sederhana yang dekat dengan pengembangan aplikasi kampus.

### Aturan Pengerjaan

- Gunakan bahasa Indonesia yang natural dan mudah dipahami.
- Jadikan materi resmi sebagai sumber utama.
- Tandai informasi tambahan yang tidak disebutkan secara eksplisit dalam materi.
- Jelaskan istilah teknis secara singkat ketika pertama kali digunakan.
- Gunakan tabel untuk membandingkan ketiga pola jika diperlukan.
- Jangan menyamakan OAuth, OpenID Connect, JWT, dan Firebase Authentication.
- Jangan mengarang detail implementasi.
- Jangan menulis atau mengubah kode.
- Jangan menjalankan perintah terminal.
- Jangan membuat atau mengubah file maupun folder.
- Jangan memasang package atau mengonfigurasi Firebase.
- Jangan mulai mengimplementasikan fitur autentikasi.
- Jangan melanjutkan ke bagian materi berikutnya sebelum saya memberikan instruksi.

### Format Jawaban

**A. Konsep Dasar Autentikasi**

**B. Perbandingan Tiga Pola Autentikasi**

**C. Perbedaan ID Token, Access Token, dan Refresh Token**

**D. Gambaran Alur Autentikasi**

**E. Model yang Digunakan dalam Codelab**

**F. Repository Pattern dan Token Refresh**

**G. Ringkasan dan Tes Pemahaman**

Pada bagian terakhir, berikan 3 pertanyaan singkat untuk menguji pemahaman saya. Jangan langsung memberikan jawabannya; tunggu saya menjawab terlebih dahulu.

Setelah selesai, berhenti dan tunggu instruksi saya untuk materi berikutnya.

# MASTER PROMPT 03 — PRAKTIKUM 1

## Login + Secure Storage + Token Refresh

### 1. Konteks

Saya sedang mengerjakan codelab Flutter Minggu 6 dari JTI Politeknik Negeri Malang.

Sumber materi:
https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#2

Bagian yang sedang dikerjakan adalah **Praktikum 1: Login + secure storage + token refresh**.

Saya ingin kamu membantu mengerjakan praktikum ini langsung pada project Flutter yang sedang terbuka di workspace Cursor.

### 2. Tujuan Praktikum

Implementasikan alur autentikasi sederhana dengan:

- Login menggunakan mock authentication provider.
- Penyimpanan access token dan refresh token secara aman.
- Pengelolaan autentikasi melalui repository pattern.
- Penambahan access token pada request API menggunakan Dio.
- Refresh access token secara otomatis ketika request memperoleh HTTP 401.
- Pengulangan request setelah refresh berhasil.
- Logout apabila refresh token tidak tersedia atau proses refresh gagal.
- Pengelolaan status autentikasi dan pembatasan akses halaman menggunakan Riverpod dan GoRouter.

### 3. Tahapan Pengerjaan

Kerjakan secara bertahap mengikuti materi resmi.

**Tahap 1 — Periksa project**

- Periksa struktur project dan file yang sudah tersedia.
- Identifikasi package, konfigurasi, serta implementasi yang sudah ada.
- Pertahankan kode yang masih relevan.
- Jangan menimpa implementasi yang sudah benar tanpa alasan.

**Tahap 2 — Secure token storage**

Implementasikan `lib/data/token_store.dart` menggunakan `flutter_secure_storage`.

Sediakan fungsi untuk:

- Menyimpan access token dan refresh token.
- Membaca masing-masing token.
- Menghapus token ketika logout.

Seluruh operasi penyimpanan token harus melalui kelas ini.

**Tahap 3 — Authentication repository**

Implementasikan `lib/data/auth_repository.dart` menggunakan mock authentication provider sesuai codelab.

Sediakan fungsi login dan refresh token. Pertahankan sifat simulasi: jangan mengklaim bahwa mock token merupakan JWT valid yang benar-benar diverifikasi oleh server.

**Tahap 4 — API client dan token refresh**

Implementasikan `lib/data/api_client.dart` menggunakan Dio.

- Tambahkan access token ke header `Authorization: Bearer ...` jika tersedia.
- Tangani HTTP 401 dengan mencoba refresh token.
- Simpan access token baru setelah refresh berhasil.
- Ulangi request awal maksimal satu kali untuk mencegah infinite retry.
- Jika refresh gagal, bersihkan sesi autentikasi dan arahkan alur aplikasi agar pengguna dapat login kembali.
- Hindari logging token atau kredensial.

**Tahap 5 — Riverpod dan autentikasi**

Implementasikan atau sesuaikan `lib/providers/auth_provider.dart`.

- Kelola status autentikasi menggunakan Riverpod.
- Tangani proses loading dan error.
- Integrasikan proses login dan logout dengan repository serta token store.
- Pastikan perubahan status autentikasi tercermin pada navigasi aplikasi.

**Tahap 6 — Halaman dan route guard**

Periksa dan sesuaikan halaman login serta konfigurasi GoRouter.

Pastikan:

- Pengguna yang belum login tidak dapat membuka halaman yang dilindungi.
- Pengguna yang sudah login dapat membuka halaman utama.
- Logout menghapus token dan mengembalikan pengguna ke halaman login.
- Navigasi tidak menyebabkan redirect loop.

**Tahap 7 — Verifikasi**

Jalankan pemeriksaan yang relevan dan perbaiki error yang ditemukan.

Verifikasi setidaknya:

1. Login berhasil dengan kredensial mock yang valid.
2. Login gagal dengan input yang tidak valid.
3. Token tersimpan dan dapat dibaca kembali.
4. Request API menggunakan access token.
5. HTTP 401 memicu proses refresh.
6. Request hanya diulang satu kali setelah refresh.
7. Kegagalan refresh mengakhiri sesi autentikasi.
8. Logout membersihkan token dan membatasi akses ke halaman privat.

Jika backend pada codelab hanya berupa simulasi, jelaskan batasan pengujian tersebut. Jangan mengklaim request ke backend sungguhan berhasil apabila tidak ada backend yang tersedia.

### 4. Aturan Implementasi

- Ikuti materi resmi sebagai acuan utama.
- Gunakan package dan arsitektur yang ditentukan codelab.
- Sesuaikan implementasi dengan versi package dan struktur project yang sudah ada.
- Jangan menghapus kode atau file yang tidak berkaitan.
- Jangan memasukkan secret atau token sungguhan ke dalam source code.
- Jangan menambahkan Firebase Authentication sungguhan jika belum diminta oleh bagian praktikum ini.
- Jangan mengimplementasikan fitur FCM terlebih dahulu.
- Jangan mengerjakan bagian codelab berikutnya.
- Jika menemukan konflik antara materi dan kondisi project, jelaskan konflik tersebut sebelum mengambil keputusan yang berisiko.
- Jangan menyatakan praktikum selesai sebelum pemeriksaan dilakukan.

### 5. Laporan Hasil

Setelah implementasi, laporkan:

1. File yang dibuat atau diubah.
2. Peran masing-masing file.
3. Fitur yang berhasil diimplementasikan.
4. Hasil pemeriksaan atau pengujian yang benar-benar dijalankan.
5. Kendala dan bagian yang belum terverifikasi.
6. Langkah manual yang perlu saya lakukan untuk membuktikan hasil praktikum.

Kerjakan praktikum ini saja. Setelah selesai, berhenti dan tunggu instruksi saya untuk bagian berikutnya.


# MASTER PROMPT 04 — PRAKTIKUM 2
## Firebase Setup + Firebase Cloud Messaging (FCM)

### 1. Konteks

Saya sedang mengerjakan codelab Flutter Minggu 6 dari JTI Politeknik Negeri Malang.

**Materi resmi:**
https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#3

Saya ingin menyelesaikan seluruh praktikum ini secara bertahap, mulai dari setup Firebase Console sampai integrasi FCM ke project Flutter yang sudah ada.

Kamu bertindak sebagai coding assistant yang memandu proses setup dan mengerjakan implementasi teknis langsung pada workspace Cursor.

**Penting:** Jangan hanya memberikan tutorial atau contoh kode. Periksa project, lakukan perubahan yang diperlukan, verifikasi hasilnya, dan pandu saya untuk langkah yang membutuhkan interaksi manual.

### 2. Target Akhir

Pada akhir praktikum, saya ingin memiliki aplikasi Flutter yang:

1. Terdaftar sebagai aplikasi Android di Firebase.
2. Menggunakan konfigurasi Firebase yang benar.
3. Menginisialisasi Firebase sebelum `runApp()`.
4. Meminta izin notifikasi kepada pengguna.
5. Mendapatkan FCM registration token.
6. Memantau perubahan token melalui `onTokenRefresh`.
7. Memiliki struktur untuk mengirim token ke backend melalui `POST /devices` apabila backend tersedia.
8. Dapat berlangganan topik `pengumuman-kampus`.
9. Dapat menerima dan menampilkan notifikasi percobaan dari Firebase Console.
10. Memiliki bukti pengujian yang dapat digunakan untuk laporan praktikum.

### 3. Aturan Utama: Kerjakan dan Pandu Secara Bertahap

- Baca materi resmi sebelum mulai mengerjakan.
- Periksa kondisi project sebelum mengubah kode.
- Kerjakan tahap demi tahap sesuai urutan di bawah.
- Lakukan sendiri semua tindakan yang bisa dilakukan melalui workspace Cursor.
- Jika suatu tahap memerlukan tindakan manual saya di Firebase Console, browser, atau perangkat Android, jelaskan langkahnya dengan detail dan berhenti sementara.
- Setelah saya mengonfirmasi tahap manual selesai, lanjutkan dari tahap tersebut tanpa mengulang semuanya.
- Jangan menganggap suatu langkah berhasil hanya karena instruksinya sudah diberikan.
- Jangan melompat ke tahap berikutnya jika tahap saat ini masih memiliki kendala penting.

### 4. Tahap 1 — Audit Project Flutter

Periksa project yang sedang terbuka.

Identifikasi:
- Nama project pada `pubspec.yaml`.
- `applicationId` Android yang aktif.
- Versi Flutter dan Dart.
- Versi serta keberadaan package yang dibutuhkan.
- Konfigurasi Gradle Android.
- `AndroidManifest.xml`.
- `lib/main.dart`.
- Struktur `lib/data/`, `lib/providers/`, `lib/messaging/`, dan `lib/pages/`.
- Implementasi login, secure storage, token refresh, Riverpod, dan GoRouter dari praktikum sebelumnya.

Jangan membuat project Flutter baru.

Jangan menghapus atau menimpa implementasi praktikum pertama yang masih benar.

Setelah audit, berikan ringkasan singkat mengenai kondisi project dan lanjutkan ke tahap berikutnya jika tidak ada hambatan.

### 5. Tahap 2 — Setup Firebase Console dari Nol

Pandu saya membuat dan mengonfigurasi Firebase project.

#### A. Membuat Firebase project

1. Buka https://console.firebase.google.com/
2. Login menggunakan akun Google.
3. Pilih opsi untuk membuat Firebase project.
4. Gunakan nama project yang mudah dikenali, misalnya `authentication-security-fcm`.
5. Ikuti proses pembuatan project sampai selesai.

Jelaskan bahwa **Firebase Project Name berbeda dari nama project Flutter dan Android `applicationId`**.

Google Analytics boleh dinonaktifkan jika tidak dibutuhkan untuk praktikum ini.

Setelah memberikan instruksi, berhenti dan tunggu konfirmasi saya.

#### B. Mendaftarkan aplikasi Android

Setelah Firebase project tersedia:

1. Buka halaman overview project.
2. Pilih opsi untuk menambahkan aplikasi Android.
3. Ambil nilai `applicationId` yang benar dari hasil audit project.
4. Masukkan nilai tersebut ke kolom Android package name.
5. Berikan nama aplikasi opsional jika diperlukan.
6. SHA-1 dan SHA-256 tidak perlu ditambahkan kecuali fitur atau konfigurasi yang digunakan memang memerlukannya.
7. Selesaikan proses registrasi aplikasi.

Jangan menggunakan nama project Firebase atau nama pada `pubspec.yaml` sebagai package name Android.

Jika `applicationId` belum bisa dipastikan, periksa konfigurasi Gradle terlebih dahulu dan jangan menebaknya.

Setelah memberikan instruksi, berhenti dan tunggu konfirmasi saya.

#### C. Mengunduh konfigurasi Firebase

1. Unduh `google-services.json` dari Firebase Console.
2. Simpan file tersebut pada lokasi berikut di project Flutter:

   `android/app/google-services.json`

3. Periksa bahwa nama file dan lokasinya benar.
4. Jangan membuat file pengganti atau konfigurasi palsu.
5. Jangan meminta saya mengirim kredensial pribadi ke percakapan.

Jika file tidak dapat diakses oleh workspace, pandu saya menempatkannya secara manual.

Setelah file tersedia, periksa keberadaannya sebelum melanjutkan.

### 6. Tahap 3 — Konfigurasi Firebase pada Android

Periksa dokumentasi resmi Firebase Flutter dan sesuaikan konfigurasi dengan versi project.

Referensi:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/cloud-messaging/flutter/client

Lakukan konfigurasi yang diperlukan untuk:

1. Plugin Google Services.
2. Konfigurasi Gradle project dan aplikasi Android.
3. Dependensi `firebase_core`.
4. Dependensi `firebase_messaging`.
5. Persyaratan minimum Android yang relevan.
6. Konfigurasi manifest apabila diperlukan.

Gunakan file Gradle yang benar sesuai struktur project, baik Kotlin DSL (`.gradle.kts`) maupun Groovy (`.gradle`).

Jangan menambahkan konfigurasi plugin secara duplikat. Periksa dahulu apakah plugin sudah diterapkan melalui mekanisme Plugins DSL atau konfigurasi Gradle yang sudah ada.

Jika konfigurasi yang disarankan codelab berbeda dengan dokumentasi versi package yang digunakan, jelaskan perbedaannya dan pilih pendekatan yang kompatibel.

Setelah perubahan, jalankan pemeriksaan build yang relevan. Jika terjadi error, perbaiki sebelum melanjutkan.

### 7. Tahap 4 — Inisialisasi Firebase

Sesuaikan `lib/main.dart` agar Firebase diinisialisasi sebelum `runApp()`.

Pastikan:

- `WidgetsFlutterBinding.ensureInitialized()` dipanggil sebelum inisialisasi Firebase.
- `Firebase.initializeApp()` diselesaikan sebelum aplikasi dijalankan.
- Inisialisasi menggunakan konfigurasi yang sesuai dengan platform.
- Konfigurasi Riverpod dan GoRouter yang sudah ada tetap berfungsi.
- Firebase tidak diinisialisasi berulang kali secara tidak perlu.

Jangan menghapus provider, router, atau konfigurasi aplikasi yang sudah digunakan.

Jika dibutuhkan konfigurasi platform khusus, implementasikan sesuai dokumentasi resmi dan jelaskan alasannya.

### 8. Tahap 5 — Implementasi PushService

Buat atau sesuaikan:

`lib/messaging/push_service.dart`

Gunakan `firebase_messaging` untuk mengelola lifecycle FCM.

Implementasikan fungsi yang sesuai untuk:

#### A. Meminta izin notifikasi

- Memanggil `FirebaseMessaging.instance.requestPermission()`.
- Memeriksa status izin yang diberikan pengguna.
- Menangani izin yang ditolak tanpa membuat aplikasi crash.
- Menjelaskan perbedaan izin notifikasi Android dan iOS jika relevan.

#### B. Mengambil FCM token

- Mengambil token menggunakan `FirebaseMessaging.instance.getToken()`.
- Menangani kondisi token belum tersedia atau terjadi error.
- Menghindari pencetakan token lengkap ke log.

#### C. Memantau perubahan token

- Mendaftarkan listener `onTokenRefresh`.
- Menyiapkan mekanisme untuk memperbarui token pada backend jika endpoint tersedia.
- Menghindari pendaftaran listener berulang kali.

#### D. Berlangganan topik

Implementasikan langganan ke topik:

`pengumuman-kampus`

Gunakan mekanisme resmi Firebase Messaging dan tangani kegagalannya.

Jangan menganggap langganan berhasil jika belum ada bukti bahwa operasi tersebut selesai.

#### E. Integrasi backend

Siapkan integrasi pengiriman token ke `POST /devices` jika backend memang tersedia dan format endpoint-nya dapat dipastikan.

- Periksa konfigurasi API client yang sudah ada.
- Jangan membuat URL backend palsu.
- Jangan mengirim token ke endpoint contoh yang tidak aktif.
- Jangan menganggap endpoint berhasil hanya karena request sudah ditulis.
- Jika backend belum tersedia, buat batas integrasi yang jelas dan laporkan bahwa pengujian server belum dapat dilakukan.

### 9. Tahap 6 — Integrasi dengan Aplikasi

Integrasikan `PushService` ke lifecycle aplikasi yang sesuai.

Pastikan:
- Inisialisasi tidak mengganggu autentikasi.
- Listener tidak terdaftar berkali-kali.
- Proses notifikasi tidak mengubah status login secara tidak sengaja.
- Tidak ada token atau secret yang dicetak ke log production.
- Background handler, jika diperlukan, didaftarkan sesuai persyaratan Firebase.
- Background handler tidak bergantung pada `BuildContext` atau widget yang sudah tidak aktif.

Jangan mengimplementasikan seluruh fitur notifikasi lanjutan, deep link, atau pengelolaan payload kompleks jika belum termasuk cakupan praktikum ini.

### 10. Tahap 7 — Pengujian Notifikasi dari Firebase Console

Setelah aplikasi berhasil dikonfigurasi, pandu saya melakukan pengujian manual.

#### A. Persiapan

1. Jalankan aplikasi pada perangkat Android atau emulator yang mendukung Google Play services dan FCM.
2. Pastikan aplikasi menggunakan konfigurasi Firebase yang benar.
3. Berikan izin notifikasi ketika diminta.
4. Pastikan aplikasi memperoleh FCM token tanpa menampilkan token lengkap ke publik.

Jika emulator tidak mendukung Google Play services atau tidak dapat menerima FCM, jelaskan kendalanya dan sarankan penggunaan perangkat fisik.

#### B. Kirim notifikasi percobaan

1. Buka Firebase Console.
2. Masuk ke bagian Messaging.
3. Buat pesan notifikasi percobaan.
4. Isi judul dan isi pesan.
5. Pilih aplikasi Android yang sudah terdaftar.
6. Ikuti metode target pengiriman yang tersedia di console.
7. Kirim pesan dan periksa hasilnya pada perangkat.

Jika console meminta pemilihan target berdasarkan perangkat atau topik, pandu saya sesuai opsi yang tersedia.

#### C. Verifikasi

Periksa:
- Apakah notifikasi benar-benar diterima.
- Apakah judul dan isi notifikasi sesuai.
- Apakah ada error di log aplikasi.
- Apakah hasil pengujian sesuai dengan kondisi foreground atau background yang sedang diuji.

Jangan menyatakan notifikasi berhasil jika belum ada bukti pengujian.

### 11. Tahap 8 — Pemeriksaan Akhir

Jalankan pemeriksaan yang relevan, misalnya:

- `flutter pub get` jika ada perubahan dependensi.
- `flutter analyze`.
- Build Android jika lingkungan memungkinkan.
- Pengujian manual pada perangkat untuk verifikasi FCM.

Periksa kembali konfigurasi dan file yang diubah.

Pastikan tidak ada:
- Dependensi duplikat.
- Konfigurasi Gradle yang saling bertentangan.
- File konfigurasi Firebase palsu.
- Token atau secret yang di-hardcode.
- Logging token sensitif.
- Perubahan tidak perlu pada implementasi praktikum pertama.

### 12. Aturan Penting

- Kerjakan langsung pada project yang sudah ada.
- Ikuti materi codelab dan dokumentasi resmi.
- Gunakan bahasa Indonesia saat menjelaskan langkah kepada saya.
- Lakukan perubahan kode secara nyata, bukan hanya memberikan contoh implementasi.
- Jangan membuat klaim pengujian yang tidak benar-benar dilakukan.
- Jangan mengubah `applicationId` tanpa alasan yang jelas dan persetujuan saya.
- Jangan menghapus konfigurasi atau file yang masih digunakan.
- Jangan meminta kredensial akun Google atau secret pribadi.
- Jangan melanjutkan otomatis melewati langkah manual Firebase Console.
- Jangan mengerjakan materi codelab berikutnya sebelum saya meminta.

### 13. Format Laporan Akhir

Setelah praktikum selesai, berikan laporan:

**A. Setup Firebase**
- Project Firebase berhasil dibuat atau belum.
- Aplikasi Android berhasil didaftarkan atau belum.
- `google-services.json` tersedia atau belum.

**B. Implementasi**
- File yang dibuat atau diubah.
- Fungsi masing-masing file.
- Integrasi Firebase dan FCM yang sudah dilakukan.

**C. Hasil Pengujian**
- Pemeriksaan yang dijalankan.
- Hasil build atau analisis.
- Hasil pengujian notifikasi yang benar-benar diamati.

**D. Kendala**
- Bagian yang gagal atau belum terverifikasi.
- Penyebab yang diketahui.
- Tindakan yang masih diperlukan.

**E. Bukti Praktikum**
- Screenshot Firebase project dan registrasi aplikasi.
- Screenshot konfigurasi aplikasi yang relevan.
- Screenshot notifikasi yang berhasil diterima.
- Log atau output pemeriksaan yang relevan tanpa membocorkan token.

Mulai dari Tahap 1 — Audit Project Flutter. Jangan langsung mengubah banyak file sebelum memahami kondisi project. Setelah setiap tahap yang membutuhkan tindakan manual saya, berhenti dan tunggu konfirmasi saya sebelum melanjutkan.


# MASTER PROMPT 05 — PRAKTIKUM 03
## Notification Permission dan Inisialisasi Local Notification

### 1. Konteks

Saya sedang mengerjakan codelab Flutter Minggu 6 dari JTI Politeknik Negeri Malang.

**Sumber materi resmi:**
https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#4

Lanjutkan project Flutter yang sama dari praktikum sebelumnya. Firebase sudah dikonfigurasi atau sedang dalam proses konfigurasi pada tahap sebelumnya.

Tugas kamu adalah membaca bagian materi yang ditunjuk oleh URL tersebut, memastikan cakupan praktikum yang benar, lalu mengimplementasikannya langsung pada workspace Cursor.

Jangan hanya menjelaskan teori atau memberikan potongan kode untuk saya salin manual.

### 2. Aturan Sebelum Implementasi

1. Baca materi resmi pada link yang diberikan.
2. Identifikasi judul dan instruksi praktikum yang tepat pada bagian tersebut.
3. Periksa implementasi Firebase dan FCM dari praktikum sebelumnya.
4. Periksa `pubspec.yaml`, `lib/main.dart`, `lib/messaging/push_service.dart`, dan konfigurasi Android yang relevan.
5. Pertahankan kode yang sudah benar.
6. Jika Firebase belum selesai dikonfigurasi, identifikasi bagian yang masih kurang dan pandu saya menyelesaikannya terlebih dahulu.
7. Jangan mengulang setup Firebase dari nol jika konfigurasi sebelumnya sudah benar.

**Penting:** Jangan mengasumsikan isi bagian hanya berdasarkan nomor URL. Pastikan cakupan pekerjaan sesuai dengan materi resmi yang benar-benar ditampilkan.

### 3. Target Implementasi

Jika sesuai dengan bagian materi yang ditunjuk, implementasikan fitur berikut.

#### A. Notification permission

- Gunakan `FirebaseMessaging.instance.requestPermission()`.
- Periksa status izin yang dikembalikan Firebase Messaging.
- Tangani status `authorized`, `provisional` jika relevan, dan izin yang ditolak.
- Pastikan aplikasi tidak crash ketika pengguna menolak izin.
- Sesuaikan perilaku dengan platform yang digunakan.
- Perhatikan izin notifikasi Android 13+ dan perbedaan perilaku iOS.

Jangan menganggap izin notifikasi diberikan secara otomatis.

#### B. Inisialisasi local notification

Jika termasuk cakupan materi, gunakan package `flutter_local_notifications` untuk menyiapkan notifikasi lokal.

- Periksa apakah package sudah tersedia.
- Inisialisasikan plugin dengan konfigurasi platform yang sesuai.
- Gunakan ikon notifikasi Android yang valid.
- Siapkan callback untuk menangani klik notifikasi.
- Pastikan inisialisasi tidak dilakukan berulang kali secara tidak perlu.
- Jangan membuat nama resource atau ikon yang tidak tersedia di project.

#### C. Integrasi dengan PushService

Tempatkan logika notifikasi pada struktur yang sesuai dengan project, terutama `lib/messaging/push_service.dart`.

- Hindari menumpuk seluruh logika notifikasi di `main.dart`.
- Pertahankan pemisahan tanggung jawab antarkomponen.
- Pastikan implementasi tidak merusak login, Riverpod, GoRouter, atau token storage.
- Jangan mencetak FCM token lengkap ke log.

#### D. Persiapan pengujian

Siapkan cara memverifikasi bahwa:
- Permintaan izin dapat dijalankan.
- Status izin dapat ditangani dengan benar.
- Inisialisasi local notification tidak menghasilkan error.
- Callback klik notifikasi dapat diproses jika fitur tersebut sudah termasuk materi.

Bedakan hasil yang telah diuji langsung dari hasil yang baru diverifikasi melalui kode.

### 4. Batasan Pengerjaan

- Ikuti cakupan materi pada link `#4`.
- Jangan mengulang implementasi praktikum sebelumnya.
- Jangan mengimplementasikan seluruh fitur FCM sekaligus jika belum termasuk bagian ini.
- Jangan mengimplementasikan deep link lengkap, semua app state, atau topic messaging lebih awal kecuali memang diminta pada bagian yang sedang dikerjakan.
- Jangan membuat backend atau endpoint palsu.
- Jangan menambahkan dependensi yang sudah tersedia.
- Jangan mengubah konfigurasi Firebase yang telah benar tanpa alasan teknis.
- Jangan menghapus kode yang masih digunakan.
- Jangan mengklaim pengujian berhasil jika belum benar-benar dilakukan.
- Jika memerlukan tindakan manual di Firebase Console atau perangkat Android, berikan instruksi yang jelas dan tunggu konfirmasi saya.

### 5. Verifikasi

Jalankan pemeriksaan yang relevan, misalnya:

- `flutter pub get` jika dependensi berubah.
- `flutter analyze`.
- Build Android jika memungkinkan.
- Pengujian manual pada perangkat atau emulator yang mendukung Firebase Messaging.

Jika muncul error:
1. Identifikasi penyebabnya.
2. Perbaiki masalah yang berkaitan dengan praktikum ini.
3. Jalankan kembali pemeriksaan yang relevan.
4. Laporkan error yang belum dapat diselesaikan.

### 6. Laporan Hasil

Setelah selesai, berikan laporan dengan format:

**A. Cakupan Materi**
- Judul bagian resmi yang dikerjakan.
- Tujuan implementasi.

**B. Perubahan Kode**
- File yang dibuat atau diubah.
- Fungsi masing-masing file.

**C. Hasil Verifikasi**
- Perintah yang dijalankan.
- Hasil analisis dan build.
- Hasil pengujian yang benar-benar diamati.

**D. Pengujian Manual**
- Langkah yang perlu saya lakukan.
- Screenshot atau bukti yang perlu disiapkan.

**E. Kendala**
- Fitur yang belum selesai.
- Penyebab dan tindakan berikutnya.

Kerjakan praktikum pada bagian ini saja. Setelah selesai, berhenti dan tunggu instruksi saya untuk melanjutkan ke bagian berikutnya.