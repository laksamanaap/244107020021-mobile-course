import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'sandiwara_lyrics.dart';

class LyricsFullscreenPage extends StatefulWidget {
  const LyricsFullscreenPage({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.volume,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onVolumeChanged,
  });

  final ValueNotifier<Duration> position;
  final ValueNotifier<Duration> duration;
  final ValueNotifier<bool> isPlaying;
  final double volume;
  final VoidCallback onTogglePlay;
  final Future<void> Function(Duration position) onSeek;
  final ValueChanged<double> onVolumeChanged;

  @override
  State<LyricsFullscreenPage> createState() => _LyricsFullscreenPageState();
}

class _LyricsFullscreenPageState extends State<LyricsFullscreenPage> {
  final _scrollController = ScrollController();
  final _lineKeys = List<GlobalKey>.generate(
    kSandiwaraLyrics.length,
    (_) => GlobalKey(),
  );
  int _lastIndex = -1;
  bool _scrubbing = false;
  bool _followLyrics = true;
  bool _programmaticScroll = false;
  int _scrollGen = 0;
  late double _volume;

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
    widget.position.addListener(_onPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPosition());
  }

  @override
  void dispose() {
    widget.position.removeListener(_onPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _onPosition() {
    if (_scrubbing) return;
    final index = lyricIndexAt(widget.position.value);
    if (index == _lastIndex) return;
    _lastIndex = index;
    setState(() {});

    if (_followLyrics) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _followLyrics) _scrollToActive();
      });
    }
  }

  Future<void> _scrollToActive() async {
    if (!_scrollController.hasClients) return;

    final gen = ++_scrollGen;
    final index = lyricIndexAt(widget.position.value);
    _programmaticScroll = true;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || gen != _scrollGen || !_scrollController.hasClients) {
      if (gen == _scrollGen) _programmaticScroll = false;
      return;
    }

    final keyContext = _lineKeys[index].currentContext;
    final renderObject = keyContext?.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      if (gen == _scrollGen) _programmaticScroll = false;
      return;
    }

    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) {
      if (gen == _scrollGen) _programmaticScroll = false;
      return;
    }

    // Baris aktif di sekitar sepertiga atas layar
    final reveal = viewport.getOffsetToReveal(renderObject, 0.32);
    final target = reveal.offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    // Kalau sudah dekat, jangan animasi ulang (lebih mulus)
    if ((target - _scrollController.offset).abs() < 8) {
      if (gen == _scrollGen) _programmaticScroll = false;
      return;
    }

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );

    if (mounted && gen == _scrollGen) {
      _programmaticScroll = false;
    }
  }

  void _onSyncTap() {
    setState(() => _followLyrics = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToActive();
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_programmaticScroll) return false;
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        _followLyrics) {
      setState(() => _followLyrics = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5C1A1E),
              AppTheme.headerBg,
              AppTheme.bgMid,
              AppTheme.bg,
            ],
            stops: [0, 0.35, 0.7, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildLyrics(),
                    // Fade soft ke music player
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 56,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x001A0C0E),
                                Color(0xCC1A0C0E),
                                Color(0xFF1A0C0E),
                              ],
                              stops: [0, 0.55, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Sandiwara Semu',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Antrian',
            onPressed: () {},
            icon: Icon(
              Icons.queue_music_rounded,
              color: Colors.white.withValues(alpha: 0.85),
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyrics() {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: ValueListenableBuilder<Duration>(
            valueListenable: widget.position,
            builder: (context, position, _) {
              final active = lyricIndexAt(position);
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      var index = 0;
                      index < kSandiwaraLyrics.length;
                      index++
                    )
                      KeyedSubtree(
                        key: _lineKeys[index],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: GestureDetector(
                            onTap: () =>
                                widget.onSeek(kSandiwaraLyrics[index].start),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              style: GoogleFonts.poppins(
                                fontSize: index == active ? 25 : 24,
                                height: 1.35,
                                fontWeight: index == active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: index == active
                                    ? Colors.white
                                    : Colors.white.withValues(
                                        alpha: index < active ? 0.28 : 0.42,
                                      ),
                              ),
                              child: Text(kSandiwaraLyrics[index].text),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: IgnorePointer(
            ignoring: _followLyrics,
            child: AnimatedOpacity(
              opacity: _followLyrics ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: _onSyncTap,
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.graphic_eq_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sync',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPlayer() {
    return Material(
      color: const Color(0xFF1A0C0E),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/sandiwara_semu.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sandiwara Semu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rumah Sakit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: widget.isPlaying,
              builder: (context, playing, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shuffle_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 22,
                    ),
                    const SizedBox(width: 18),
                    Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onTogglePlay,
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppTheme.bg,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 30,
                    ),
                    const SizedBox(width: 18),
                    Icon(
                      Icons.repeat_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 22,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<Duration>(
              valueListenable: widget.position,
              builder: (context, pos, _) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: widget.duration,
                  builder: (context, dur, _) {
                    final totalMs = dur.inMilliseconds <= 0
                        ? 1
                        : dur.inMilliseconds;
                    final value = (pos.inMilliseconds / totalMs).clamp(
                      0.0,
                      1.0,
                    );
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: AppTheme.brandSoft,
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                            thumbColor: Colors.white,
                            overlayColor: AppTheme.brandSoft.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: value,
                            onChangeStart: (_) => _scrubbing = true,
                            onChanged: (v) {
                              final next = Duration(
                                milliseconds: (v * totalMs).round(),
                              );
                              widget.position.value = next;
                            },
                            onChangeEnd: (v) async {
                              final next = Duration(
                                milliseconds: (v * totalMs).round(),
                              );
                              await widget.onSeek(next);
                              _scrubbing = false;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fmt(pos),
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _fmt(dur),
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
