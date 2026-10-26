import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'lms_content.dart';

/// Dashboard LMS — layout tetap grid + list, konten kelas kampus.
class SpotifyHomePage extends StatefulWidget {
  const SpotifyHomePage({super.key, this.onOpenPlaybox});

  final VoidCallback? onOpenPlaybox;

  @override
  State<SpotifyHomePage> createState() => _SpotifyHomePageState();
}

class _SpotifyHomePageState extends State<SpotifyHomePage> {
  int _filter = 0;

  static const _quickAccess = [
    ('Pemrograman Mobile', LmsImages.authFcm),
    ('Basis Data Lanjut', LmsImages.basisData),
    ('Tugas minggu ini', null),
    ('Jaringan Komputer', LmsImages.quizSubnetting),
    ('ERD & Relasi', LmsImages.erdRelasi),
    ('Praktikum JTI', LmsImages.authFcm),
  ];

  static const _recent = [
    (
      'Modul 4 — ERD & Relasi',
      'Basis Data Lanjut · 80%',
      LmsImages.erdRelasi,
      false,
    ),
    (
      'Pertemuan 6 — Auth & FCM',
      'Pemrograman Mobile · berlangsung',
      LmsImages.authFcm,
      true,
    ),
    (
      'Quiz subnetting',
      'Jaringan Komputer · deadline Jumat',
      LmsImages.quizSubnetting,
      false,
    ),
    (
      'Normalisasi tabel',
      'Basis Data Lanjut · modul 5',
      LmsImages.basisData,
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppTheme.pageDecoration,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilters()),
          SliverToBoxAdapter(child: _buildQuickGrid()),
          SliverToBoxAdapter(child: _sectionTitle('Lanjutkan belajar')),
          ..._recent.map(_buildRecentTile),
          SliverToBoxAdapter(child: _sectionTitle('Kelas minggu ini')),
          SliverToBoxAdapter(child: _buildStations()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final labels = ['Semua', 'Kelas', 'Tugas'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _filter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _filter == i ? AppTheme.brand : AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filter == i
                        ? AppTheme.brandSoft
                        : AppTheme.hairline,
                  ),
                  boxShadow: _filter == i ? null : AppTheme.cardShadow,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: _filter == i ? AppTheme.onBrand : AppTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _quickTile(_quickAccess[row * 2])),
                const SizedBox(width: 8),
                Expanded(child: _quickTile(_quickAccess[row * 2 + 1])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickTile((String, String?) item) {
    final (title, image) = item;
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: widget.onOpenPlaybox,
        splashColor: AppTheme.brand.withValues(alpha: 0.12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.hairline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                if (image != null)
                  Image.asset(image, width: 56, height: 56, fit: BoxFit.cover)
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.brand, AppTheme.brandSoft],
                      ),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: AppTheme.onBrand,
                      size: 22,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.brandSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTile((String, String, String, bool) item) {
    final (title, meta, image, playing) = item;
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: widget.onOpenPlaybox,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          decoration: playing
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.brandSoft, width: 1.5),
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(image, width: 52, height: 52, fit: BoxFit.cover),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: playing ? AppTheme.brandDeep : AppTheme.text,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          meta,
          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (playing)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.brandSoft,
                  size: 18,
                ),
              ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.muted.withValues(alpha: 0.85),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStations() {
    final classes = [
      (
        'PemMob TI-3C',
        LmsImages.authFcm,
        const Color(0xFF1B7A8F),
        const Color(0xFF4FB3C5),
        'HARI INI',
      ),
      (
        'Basis Data',
        LmsImages.basisData,
        const Color(0xFF2F6FAD),
        const Color(0xFF6AA6D9),
        'RABU',
      ),
      (
        'Jaringan',
        LmsImages.quizSubnetting,
        const Color(0xFF2E8B6A),
        const Color(0xFF62C49A),
        'KAMIS',
      ),
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: classes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (name, image, c1, c2, badge) = classes[index];
          return GestureDetector(
            onTap: widget.onOpenPlaybox,
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c1, c2],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 14,
                      ),
                      const Spacer(),
                      Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundImage: AssetImage(image),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mini-player rekaman kelas di atas bottom nav.
class SpotifyMiniPlayer extends StatelessWidget {
  const SpotifyMiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      elevation: 8,
      shadowColor: const Color(0x220D3344),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.brandSoft.withValues(alpha: 0.45),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          LmsImages.authFcm,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pertemuan 6 · Auth, Security & FCM',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 12,
                                color: AppTheme.brand,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Pemrograman Mobile',
                                style: TextStyle(
                                  color: AppTheme.brand,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onTap,
                      tooltip: 'Lihat detail',
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppTheme.brand,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
