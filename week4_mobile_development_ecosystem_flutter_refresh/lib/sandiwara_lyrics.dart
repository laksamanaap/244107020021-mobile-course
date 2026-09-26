class LyricLine {
  const LyricLine(this.start, this.text);

  final Duration start;
  final String text;
}

Duration _t(int m, int s, [int hundredths = 0]) =>
    Duration(minutes: m, seconds: s, milliseconds: hundredths * 10);

/// Timing dari LRC Sandiwara Semu (≈04:24) — sync ke audio asli.
const Duration kSandiwaraDuration = Duration(minutes: 4, seconds: 24);

const String kSandiwaraAudioAsset = 'audio/sandiwara_semu.mp3';

final List<LyricLine> kSandiwaraLyrics = [
  LyricLine(_t(0, 0), '♪ Sandiwara Semu — Rumah Sakit'),
  LyricLine(_t(0, 12, 91), 'Layaknya permaisuri sang raja'),
  LyricLine(_t(0, 17, 15), 'Dia duduk bermahkota di singgasana'),
  LyricLine(_t(0, 24, 47), 'Bertaburkan kilau intan permata'),
  LyricLine(_t(0, 28, 81), 'Dan menyilaukan mata yang melihatnya'),
  LyricLine(_t(0, 35, 97), 'Semua terpesona padanya'),
  LyricLine(_t(0, 41, 82), 'Wajah nan jelita'),
  LyricLine(_t(0, 47, 52), 'Senyum manis ramah menggoda'),
  LyricLine(_t(0, 53, 39), 'Pada siapa saja'),
  LyricLine(_t(1, 4, 81), 'Namun sayang semuanya tak nyata'),
  LyricLine(_t(1, 8, 96), 'Kau hanyalah fatamorgana'),
  LyricLine(_t(1, 13, 25), 'Tak seindah tampaknya'),
  LyricLine(_t(1, 15, 82), 'Dan kau buat orang tergila-gila'),
  LyricLine(_t(1, 20, 53), 'Memuja lalu terpedaya'),
  LyricLine(_t(1, 24, 86), 'Tertipu sandiwara semu'),
  LyricLine(_t(1, 39, 65), 'Mudahnya kau mainkan logika'),
  LyricLine(_t(1, 43, 94), 'Semua tipu daya dan pura-pura'),
  LyricLine(_t(1, 50, 87), 'Tak kuasa, ku pun ikut percaya'),
  LyricLine(_t(1, 55, 59), 'Terjerat janji surga, terbawa suasana'),
  LyricLine(_t(2, 2, 64), 'Semua terpesona padanya'),
  LyricLine(_t(2, 8, 59), 'Wajah nan jelita'),
  LyricLine(_t(2, 14, 29), 'Senyum manis ramah menggoda'),
  LyricLine(_t(2, 20, 13), 'Pada siapa saja'),
  LyricLine(_t(2, 31, 53), 'Namun sayang semuanya tak nyata'),
  LyricLine(_t(2, 35, 68), 'Kau hanyalah fatamorgana'),
  LyricLine(_t(2, 40, 3), 'Tak seindah tampaknya'),
  LyricLine(_t(2, 42, 56), 'Dan kau buat orang tergila-gila'),
  LyricLine(_t(2, 47, 25), 'Memuja lalu terpedaya'),
  LyricLine(_t(2, 51, 55), 'Tertipu sandiwara semu'),
  LyricLine(_t(2, 56, 64), 'Kau beri harapan yang palsu'),
  LyricLine(_t(2, 59, 85), "Semua hanya 'tuk puaskan hasratmu"),
  LyricLine(_t(3, 5, 67), 'Bila telah habis kau hisap madu'),
  LyricLine(_t(3, 12, 19), 'Kau tinggalkan dia tertunduk layu'),
  LyricLine(_t(3, 40, 91), 'Namun sayang semuanya tak nyata'),
  LyricLine(_t(3, 45, 5), 'Kau hanyalah fatamorgana'),
  LyricLine(_t(3, 49, 39), 'Tak seindah tampaknya'),
  LyricLine(_t(3, 51, 94), 'Dan kau buat orang tergila-gila'),
  LyricLine(_t(3, 56, 67), 'Memuja lalu terpedaya'),
  LyricLine(_t(4, 0, 95), 'Tertipu sandiwara'),
  LyricLine(_t(4, 6, 77), 'Terjerat janji surga'),
  LyricLine(_t(4, 14, 96), 'Semu'),
];

int lyricIndexAt(Duration position) {
  var index = 0;
  for (var i = 0; i < kSandiwaraLyrics.length; i++) {
    if (position >= kSandiwaraLyrics[i].start) {
      index = i;
    } else {
      break;
    }
  }
  return index;
}
