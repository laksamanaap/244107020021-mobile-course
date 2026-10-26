# Refleksi

## Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?

Karena refresh token itu tiket jangka panjang. Kalau access token habis, tiket ini yang dipakai minta yang baru, tanpa login lagi. SharedPreferences di Android cuma file biasa, tidak dienkripsi. Orang yang bisa baca penyimpanan app (root, backup, malware) bisa nyontek isinya.

Kalau bocor, pelaku tidak butuh password. Refresh ditukar jadi access token baru, API kampus dikira saya yang panggil. Access token yang umurnya pendek masih merepotkan, tapi refresh yang tahan lama lebih parah, kayak kunci cadangan akun.

Di project ini saya taruh access dan refresh di `flutter_secure_storage` (Keystore), bukan SharedPreferences.

## Apa yang rusak bila onTokenRefresh diabaikan selama satu semester perkuliahan?

Token FCM itu bisa ganti sendiri. Reinstall, clear data, kadang rotasi dari Firebase. Kalau app diam saja, server atau Console masih nyimpan token lama.

Yang rusak: pengumuman kuliah, pindah jadwal, tagihan, tidak sampai ke HP. App-nya kelihatan normal karena login masih bisa. Token login sama token push itu beda. Login sukses tidak otomatis bikin notifikasi hidup lagi.

Di kode saya, `onTokenRefresh` sudah didengarkan. Yang belum: kirim token baru ke `POST /devices`, karena backend kampus belum ada. Listenernya tetap saya pasang biar nanti tinggal disambung.

## Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.

Topik untuk siaran. Banyak orang subscribe nama yang sama, isinya satu. Contoh: `pengumuman-kampus`, "kampus tutup 28 Oktober", atau "kelas Mobile pindah ke A2 jam 13.00" buat semua yang ambil kelas itu.

Token perangkat untuk satu HP. Buat pesan yang tidak boleh kebaca orang lain. Contoh: nilai UTS, tagihan SPP, KRS yang ditolak. App ini sudah subscribe `pengumuman-kampus`. Pesan personal belum, nunggu backend yang nyimpan token per user.

## Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?

Saya tidak kirim FCM token ke `example-campus-api.test`. Itu mock, bukan API kampus. Kalau dikirim ke situ, seolah-olah backend-nya sudah selesai.

Token penuh tidak saya print dan tidak saya screenshot. Di Profil cukup 12 karakter.

Saya juga tidak bilang tiga state sudah lulus. Yang ada buktinya baru foreground. Background dan terminated handlernya ada, klik ke rute belum saya rekam.

Waktu tes di Console, saya sempat masuk In-App Messaging (kartu/modal). Itu salah menu. Yang bener Notifications / Cloud Messaging.

Wizard Firebase nyuruh nambah firebase-bom dan analytics di Gradle. Saya skip, takut dobel sama package FlutterFire. Cukup plugin google-services.

`encryptedSharedPreferences` di secure storage v11 sudah tidak ada. Saya ganti `AndroidOptions()` yang AES-GCM.

Template `campus_notify` kosong juga tidak saya ikut. Auth dan FCM saya tempel ke LMS yang sudah ada.

Intinya AI boleh bantu kerangka, tapi yang klaimnya tidak ketemu di HP atau endpointnya fiktif, saya tidak pakai.
