/// Aset dan data konten Campus LMS.
abstract final class LmsImages {
  static const authFcm = 'assets/images/auth_fcm.jpg';
  static const basisData = 'assets/images/basis_data.jpg';
  static const erdRelasi = 'assets/images/erd_relasi.jpg';
  static const quizSubnetting = 'assets/images/quiz_subnetting.jpg';
}

class LmsMaterial {
  const LmsMaterial({
    required this.title,
    required this.course,
    required this.image,
    this.meta = '',
  });

  final String title;
  final String course;
  final String image;
  final String meta;
}

abstract final class LmsCatalog {
  static const current = LmsMaterial(
    title: 'Pertemuan 6 — Auth & FCM',
    course: 'Pemrograman Mobile',
    image: LmsImages.authFcm,
    meta: 'Modul 6 · Praktikum',
  );

  static const upcoming = [
    LmsMaterial(
      title: 'Modul 4 — ERD & Relasi',
      course: 'Basis Data Lanjut',
      image: LmsImages.erdRelasi,
      meta: 'Progress 80%',
    ),
    LmsMaterial(
      title: 'Quiz subnetting',
      course: 'Jaringan Komputer',
      image: LmsImages.quizSubnetting,
      meta: 'Deadline Jumat',
    ),
    LmsMaterial(
      title: 'Normalisasi tabel',
      course: 'Basis Data Lanjut',
      image: LmsImages.basisData,
      meta: 'Modul 5',
    ),
  ];
}
