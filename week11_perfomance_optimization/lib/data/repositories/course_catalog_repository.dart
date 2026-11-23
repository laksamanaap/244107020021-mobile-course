import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/content/lms_content.dart';

class CourseListItem {
  const CourseListItem({
    required this.title,
    required this.subtitle,
    this.asset,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? asset;
  final String? imageUrl;
}

class CourseCatalogRepository {
  CourseCatalogRepository({
    this.pageSize = 6,
    this.delay = const Duration(milliseconds: 140),
  });

  final int pageSize;
  final Duration delay;

  static const catalog = <CourseListItem>[
    CourseListItem(
      title: 'Pemrograman Mobile',
      subtitle: 'TI-3C · 12 pertemuan',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'Basis Data Lanjut',
      subtitle: 'TI-3C · 10 pertemuan',
      asset: LmsImages.basisData,
    ),
    CourseListItem(title: 'Tugas terkumpul', subtitle: '4 berkas minggu ini'),
    CourseListItem(
      title: 'Jaringan Komputer',
      subtitle: 'Praktikum · Lab JTI',
      asset: LmsImages.quizSubnetting,
    ),
    CourseListItem(
      title: 'ERD & Relasi',
      subtitle: 'Modul 4 · progress 80%',
      asset: LmsImages.erdRelasi,
    ),
    CourseListItem(
      title: 'Normalisasi tabel',
      subtitle: 'Basis Data · modul 5',
      asset: LmsImages.basisData,
    ),
    CourseListItem(
      title: 'Poster pengumuman JTI',
      subtitle: 'Gambar dari jaringan, disimpan di cache',
      asset: LmsImages.authFcm,
      imageUrl: 'https://picsum.photos/id/180/600/400',
    ),
    CourseListItem(
      title: 'Quiz subnetting',
      subtitle: 'Deadline Jumat · 20 soal',
      asset: LmsImages.quizSubnetting,
    ),
    CourseListItem(
      title: 'Secure storage',
      subtitle: 'Token tidak disimpan di SharedPreferences',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'Dio dan HTTP 401',
      subtitle: 'Interceptor refresh sekali',
      asset: LmsImages.erdRelasi,
    ),
    CourseListItem(
      title: 'FCM type list',
      subtitle: 'Masuk kotak masuk, hilang saat dibaca',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'FCM type icon',
      subtitle: 'Status bar, tanpa suara',
      asset: LmsImages.basisData,
    ),
    CourseListItem(
      title: 'FCM type sound',
      subtitle: 'Heads-up dan bunyi',
      asset: LmsImages.quizSubnetting,
    ),
    CourseListItem(
      title: 'Peta kampus',
      subtitle: 'Zona kelas dan titik praktikum',
      asset: LmsImages.erdRelasi,
    ),
    CourseListItem(
      title: 'Absensi kamera',
      subtitle: 'Foto kehadiran ke galeri',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'Topik pengumuman-kampus',
      subtitle: 'Langganan FCM untuk siaran',
      asset: LmsImages.basisData,
    ),
    CourseListItem(
      title: 'Const widget',
      subtitle: 'Bagian statis tidak ikut rebuild filter',
      asset: LmsImages.quizSubnetting,
    ),
    CourseListItem(
      title: 'ListView.builder',
      subtitle: 'Item di luar layar tidak dibangun',
      asset: LmsImages.erdRelasi,
    ),
    CourseListItem(
      title: 'Cache gambar',
      subtitle: 'Decode mengikuti ukuran tile',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'Stale-while-revalidate',
      subtitle: 'Notifikasi tampil dari cache, lalu disegarkan',
      asset: LmsImages.basisData,
    ),
    CourseListItem(
      title: 'RepaintBoundary',
      subtitle: 'Tile gambar tidak ikut repaint header',
      asset: LmsImages.quizSubnetting,
    ),
    CourseListItem(
      title: 'Pagination',
      subtitle: 'Halaman berikutnya saat mendekati bawah',
      asset: LmsImages.erdRelasi,
    ),
    CourseListItem(
      title: 'Profil mahasiswa',
      subtitle: 'Laksamana AryaPutra · 244107020021',
      asset: LmsImages.authFcm,
    ),
    CourseListItem(
      title: 'Jadwal TI-3C',
      subtitle: 'PemMob, basis data, jaringan',
      asset: LmsImages.basisData,
    ),
  ];

  Future<List<CourseListItem>> fetchPage(int page) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (page < 1) return const [];
    final start = (page - 1) * pageSize;
    if (start >= catalog.length) return const [];
    final end = start + pageSize;
    return catalog.sublist(start, end > catalog.length ? catalog.length : end);
  }
}

final courseCatalogRepositoryProvider = Provider<CourseCatalogRepository>(
  (ref) => CourseCatalogRepository(),
);
