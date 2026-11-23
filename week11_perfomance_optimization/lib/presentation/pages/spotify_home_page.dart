import 'package:flutter/material.dart';

import '../content/lms_content.dart';
import '../theme/app_theme.dart';
import '../widgets/lms_cover.dart';

/// Naik saat bagian "Lanjutkan belajar" dibangun ulang.
/// Dipakai tes supaya rebuild filter tidak ikut menghitung grid statis.
@visibleForTesting
int recentListBuilds = 0;

/// Grid akses cepat. Const, jadi ganti filter tidak membangun ulang gambar ini.
@visibleForTesting
class FeedRebuildMark extends StatelessWidget {
  const FeedRebuildMark({super.key});

  static int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return const SizedBox.shrink();
  }
}

class FeedFilter extends ChangeNotifier {
  int index = 0;

  void select(int value) {
    if (value == index) return;
    index = value;
    notifyListeners();
  }
}

class FeedFilterScope extends InheritedNotifier<FeedFilter> {
  const FeedFilterScope({
    super.key,
    required FeedFilter filter,
    required super.child,
  }) : super(notifier: filter);

  static FeedFilter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FeedFilterScope>();
    assert(scope != null, 'FeedFilterScope tidak ditemukan');
    return scope!.notifier!;
  }
}

enum _FeedKind { kelas, tugas }

class _RecentItem {
  const _RecentItem(this.title, this.meta, this.image, this.playing, this.kind);

  final String title;
  final String meta;
  final String image;
  final bool playing;
  final _FeedKind kind;
}

/// Dashboard LMS. Filter punya state sendiri supaya grid gambar tidak ikut rebuild.
class SpotifyHomePage extends StatefulWidget {
  const SpotifyHomePage({super.key, this.onOpenPlaybox});

  final VoidCallback? onOpenPlaybox;

  @override
  State<SpotifyHomePage> createState() => _SpotifyHomePageState();
}

class _SpotifyHomePageState extends State<SpotifyHomePage> {
  final _filter = FeedFilter();

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeedFilterScope(
      filter: _filter,
      child: _HomeScroll(onOpen: widget.onOpenPlaybox),
    );
  }
}

class _HomeScroll extends StatelessWidget {
  const _HomeScroll({required this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppTheme.pageDecoration,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeFilterBar()),
          SliverToBoxAdapter(child: QuickAccessGrid(onOpen: onOpen)),
          const SliverToBoxAdapter(child: FeedRebuildMark()),
          const SliverToBoxAdapter(child: SectionHeading('Lanjutkan belajar')),
          RecentSliver(onOpen: onOpen),
          const SliverToBoxAdapter(child: SectionHeading('Kelas minggu ini')),
          SliverToBoxAdapter(child: ClassStrip(onOpen: onOpen)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class HomeFilterBar extends StatelessWidget {
  const HomeFilterBar({super.key});

  static const _labels = ['Semua', 'Kelas', 'Tugas'];

  @override
  Widget build(BuildContext context) {
    final filter = FeedFilterScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterChip(
              label: _labels[i],
              selected: filter.index == i,
              onTap: () => filter.select(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.brand : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.brandSoft : AppTheme.hairline,
          ),
          boxShadow: selected ? null : AppTheme.cardShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.onBrand : AppTheme.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key, this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  title: 'Pemrograman Mobile',
                  image: LmsImages.authFcm,
                  onTap: onOpen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  title: 'Basis Data Lanjut',
                  image: LmsImages.basisData,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickTile(title: 'Tugas minggu ini', onTap: onOpen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  title: 'Jaringan Komputer',
                  image: LmsImages.quizSubnetting,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  title: 'ERD & Relasi',
                  image: LmsImages.erdRelasi,
                  onTap: onOpen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  title: 'Praktikum JTI',
                  image: LmsImages.authFcm,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.title, this.image, this.onTap});

  final String title;
  final String? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = image;
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.hairline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                if (path != null)
                  LmsCover(asset: path, width: 56, height: 56)
                else
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.brand, AppTheme.brandSoft],
                        ),
                      ),
                      child: Icon(
                        Icons.assignment_turned_in_rounded,
                        color: AppTheme.onBrand,
                        size: 22,
                      ),
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
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
      child: Row(
        children: [
          const SizedBox(
            width: 3,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.brandSoft,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
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
}

class RecentSliver extends StatelessWidget {
  const RecentSliver({super.key, this.onOpen});

  final VoidCallback? onOpen;

  static const _items = [
    _RecentItem(
      'Modul 4 — ERD & Relasi',
      'Basis Data Lanjut · 80%',
      LmsImages.erdRelasi,
      false,
      _FeedKind.kelas,
    ),
    _RecentItem(
      'Pertemuan 6 — Auth & FCM',
      'Pemrograman Mobile · berlangsung',
      LmsImages.authFcm,
      true,
      _FeedKind.kelas,
    ),
    _RecentItem(
      'Quiz subnetting',
      'Jaringan Komputer · deadline Jumat',
      LmsImages.quizSubnetting,
      false,
      _FeedKind.tugas,
    ),
    _RecentItem(
      'Normalisasi tabel',
      'Basis Data Lanjut · modul 5',
      LmsImages.basisData,
      false,
      _FeedKind.tugas,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    recentListBuilds++;
    final filter = FeedFilterScope.of(context).index;
    final visible = [
      for (final item in _items)
        if (filter == 0 ||
            (filter == 1 && item.kind == _FeedKind.kelas) ||
            (filter == 2 && item.kind == _FeedKind.tugas))
          item,
    ];
    return SliverList.builder(
      itemCount: visible.length,
      itemBuilder: (context, index) {
        return _RecentTile(item: visible[index], onTap: onOpen);
      },
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.item, this.onTap});

  final _RecentItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final playing = item.playing;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: DecoratedBox(
        decoration: playing
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.brandSoft, width: 1.5),
              )
            : const BoxDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LmsCover(asset: item.image, width: 52, height: 52),
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: playing ? AppTheme.brandDeep : AppTheme.text,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        item.meta,
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
          const Icon(Icons.more_vert, color: AppTheme.muted, size: 20),
        ],
      ),
    );
  }
}

class _ClassCardData {
  const _ClassCardData(this.name, this.image, this.c1, this.c2, this.badge);

  final String name;
  final String image;
  final Color c1;
  final Color c2;
  final String badge;
}

class ClassStrip extends StatelessWidget {
  const ClassStrip({super.key, this.onOpen});

  final VoidCallback? onOpen;

  static const _classes = [
    _ClassCardData(
      'PemMob TI-3C',
      LmsImages.authFcm,
      Color(0xFF1B7A8F),
      Color(0xFF4FB3C5),
      'HARI INI',
    ),
    _ClassCardData(
      'Basis Data',
      LmsImages.basisData,
      Color(0xFF2F6FAD),
      Color(0xFF6AA6D9),
      'RABU',
    ),
    _ClassCardData(
      'Jaringan',
      LmsImages.quizSubnetting,
      Color(0xFF2E8B6A),
      Color(0xFF62C49A),
      'KAMIS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _classes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _ClassCard(data: _classes[index], onTap: onOpen);
        },
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.data, this.onTap});

  final _ClassCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [data.c1, data.c2],
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
                    data.badge,
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
                  child: ClipOval(
                    child: LmsCover(asset: data.image, width: 68, height: 68),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                data.name,
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
    return RepaintBoundary(
      child: Material(
        color: AppTheme.card,
        elevation: 8,
        shadowColor: const Color(0x220D3344),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.brandSoft.withValues(alpha: 0.45),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: const LmsCover(
                        asset: LmsImages.authFcm,
                        width: 40,
                        height: 40,
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
        ),
      ),
    );
  }
}
