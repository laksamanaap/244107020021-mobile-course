import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Home layout ala music app, disesuaikan brand merah Music Playbox.
class SpotifyHomePage extends StatefulWidget {
  const SpotifyHomePage({super.key, this.onOpenPlaybox});

  final VoidCallback? onOpenPlaybox;

  @override
  State<SpotifyHomePage> createState() => _SpotifyHomePageState();
}

class _SpotifyHomePageState extends State<SpotifyHomePage> {
  // Design system merah brand
  static const _brand = Color.fromARGB(255, 161, 29, 29);
  static const _brandSoft = Color(0xFFC44A4A);
  static const _bg = Color(0xFF140A0B);
  static const _bgMid = Color(0xFF1E1012);
  static const _card = Color(0xFF2A1719);
  static const _cardLift = Color(0xFF3A1F22);
  static const _muted = Color(0xFFC9A8A8);

  int _filter = 0;

  static const _quickAccess = [
    ('Sandiwara Semu', 'assets/images/sandiwara_semu.jpg'),
    ('Magnolia', 'assets/images/magnolia-celebration.jpg'),
    ('Liked Songs', null),
    ('Rumah Sakit', 'assets/images/sandiwara_semu.jpg'),
    ('Celebration', 'assets/images/magnolia-celebration.jpg'),
    ('Indie Indo', 'assets/images/sandiwara_semu.jpg'),
  ];

  static const _recent = [
    ('Ini Abadi', 'Perunggu', 'assets/images/magnolia-celebration.jpg', false),
    (
      'Sandiwara Semu',
      'Rumah Sakit',
      'assets/images/sandiwara_semu.jpg',
      true,
    ),
    (
      'Magnolia',
      'Magnolia Celebration',
      'assets/images/magnolia-celebration.jpg',
      false,
    ),
    ('Fatamorgana', 'Rumah Sakit', 'assets/images/sandiwara_semu.jpg', false),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.headerBg,
            _bgMid,
            _bg,
          ],
          stops: [0, 0.22, 0.5],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilters()),
          SliverToBoxAdapter(child: _buildQuickGrid()),
          SliverToBoxAdapter(child: _sectionTitle('Putaran terakhirmu')),
          ..._recent.map(_buildRecentTile),
          SliverToBoxAdapter(child: _sectionTitle('Stasiun rekomendasi')),
          SliverToBoxAdapter(child: _buildStations()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final labels = ['Semua', 'Musik', 'Podcast'];
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
                  color: _filter == i ? _brand : _cardLift,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filter == i
                        ? _brandSoft.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: _filter == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
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
      color: _card,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpenPlaybox,
        splashColor: _brand.withValues(alpha: 0.25),
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
                      colors: [_brand, Color(0xFFE8A0A0)],
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
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
                    color: Colors.white,
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
              color: _brandSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTile((String, String, String, bool) item) {
    final (title, artist, image, playing) = item;
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: widget.onOpenPlaybox,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          decoration: playing
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _brandSoft, width: 1.5),
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
            color: playing ? _brandSoft : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          artist,
          style: const TextStyle(color: _muted, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (playing)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: _brandSoft,
                  size: 18,
                ),
              ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: _muted.withValues(alpha: 0.85),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStations() {
    final stations = [
      (
        'Sandiwara Radio',
        'assets/images/sandiwara_semu.jpg',
        const Color(0xFF8B1E1E),
        const Color(0xFFC44A4A),
      ),
      (
        'Magnolia Radio',
        'assets/images/magnolia-celebration.jpg',
        const Color(0xFF5C1518),
        const Color(0xFFA11D1D),
      ),
      (
        'Indie Mix',
        'assets/images/sandiwara_semu.jpg',
        const Color(0xFF3D1014),
        const Color(0xFF7A2E35),
      ),
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (name, image, c1, c2) = stations[index];
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.radio_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 14,
                      ),
                      const Spacer(),
                      Text(
                        'RADIO',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
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
                          color: Colors.white.withValues(alpha: 0.35),
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

/// Mini-player dengan aksen merah brand.
class SpotifyMiniPlayer extends StatelessWidget {
  const SpotifyMiniPlayer({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onTap,
  });

  final bool isPlaying;
  final ValueNotifier<Duration> position;
  final ValueNotifier<Duration> duration;
  final VoidCallback onTogglePlay;
  final VoidCallback onTap;

  static const _bar = Color(0xFF241214);
  static const _brand = Color.fromARGB(255, 161, 29, 29);
  static const _brandSoft = Color(0xFFC44A4A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bar,
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
                          color: _brandSoft.withValues(alpha: 0.45),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          'assets/images/sandiwara_semu.jpg',
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
                            'Sandiwara Semu • Rumah Sakit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.speaker_rounded,
                                size: 12,
                                color: _brandSoft,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'LAKSAMANA',
                                style: TextStyle(
                                  color: _brandSoft,
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
                      onPressed: () {},
                      icon: Icon(
                        Icons.devices_rounded,
                        color: Colors.white.withValues(alpha: 0.65),
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: onTogglePlay,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: _brand,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<Duration>(
              valueListenable: position,
              builder: (context, pos, _) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: duration,
                  builder: (context, dur, _) {
                    final total = dur.inMilliseconds;
                    final progress = total <= 0
                        ? 0.0
                        : (pos.inMilliseconds / total).clamp(0.0, 1.0);
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: _brandSoft,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
