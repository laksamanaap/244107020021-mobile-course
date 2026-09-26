import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'camera_home_page.dart';
import 'location_map_page.dart';
import 'lyrics_fullscreen_page.dart';
import 'sandiwara_lyrics.dart';
import 'spotify_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (_) {
    cameras = [];
  }

  runApp(MyAppWeek4(cameras: cameras));
}

class MyAppWeek4 extends StatelessWidget {
  const MyAppWeek4({super.key, this.cameras = const []});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Case Music App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.bg,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.brand,
          brightness: Brightness.dark,
          primary: AppTheme.brand,
        ),
      ),
      home: MusicPlayboxPage(cameras: cameras),
    );
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

class MusicPlayboxPage extends StatefulWidget {
  const MusicPlayboxPage({super.key, this.cameras = const []});

  final List<CameraDescription> cameras;

  @override
  State<MusicPlayboxPage> createState() => _MusicPlayboxPageState();
}

class _MusicPlayboxPageState extends State<MusicPlayboxPage> {
  SampleItem? selectedItem;
  double volume = 50;
  final ScrollController _controller = ScrollController();
  int _navIndex = 0;

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> _lyricPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _audioDuration = ValueNotifier(
    kSandiwaraDuration,
  );
  bool _audioReady = false;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _durationSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(AssetSource(kSandiwaraAudioAsset));
      await _player.setVolume(volume / 100);
      _posSub = _player.onPositionChanged.listen((pos) {
        _lyricPosition.value = pos;
      });
      _durationSub = _player.onDurationChanged.listen((d) {
        if (d > Duration.zero) _audioDuration.value = d;
      });
      _completeSub = _player.onPlayerComplete.listen((_) {
        _isPlaying.value = false;
        _lyricPosition.value = Duration.zero;
        setState(() {});
      });
      _audioReady = true;
    } catch (e) {
      debugPrint('Audio init failed: $e');
      _audioReady = false;
    }
  }

  void _selectTab(int index) {
    setState(() => _navIndex = index);
  }

  Future<void> _togglePlay() async {
    if (!_audioReady) {
      await _initAudio();
      if (!_audioReady) return;
    }

    if (_isPlaying.value) {
      await _player.pause();
      _isPlaying.value = false;
    } else {
      final dur = _audioDuration.value;
      final pos = _lyricPosition.value;
      if (dur > Duration.zero &&
          pos >= dur - const Duration(milliseconds: 400)) {
        await _player.seek(Duration.zero);
        _lyricPosition.value = Duration.zero;
      }

      final state = _player.state;
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        await _player.play(AssetSource(kSandiwaraAudioAsset));
      } else {
        await _player.resume();
      }
      _isPlaying.value = true;
    }
    setState(() {});
  }

  Future<void> _seekTo(Duration position) async {
    if (!_audioReady) return;
    await _player.seek(position);
    _lyricPosition.value = position;
  }

  Future<void> _setVolume(double value) async {
    setState(() => volume = value);
    if (_audioReady) {
      await _player.setVolume(value / 100);
    }
  }

  void _openLyricsFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: LyricsFullscreenPage(
                position: _lyricPosition,
                duration: _audioDuration,
                isPlaying: _isPlaying,
                volume: volume,
                onTogglePlay: _togglePlay,
                onSeek: _seekTo,
                onVolumeChanged: _setVolume,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _completeSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    _isPlaying.dispose();
    _lyricPosition.dispose();
    _audioDuration.dispose();
    _controller.dispose();
    super.dispose();
  }

  void openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.5;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Music',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          tooltip: 'Tutup',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: _controller,
                      interactive: true,
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: const [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text('Layaknya permaisuri sang raja'),
                                  Text('Dia duduk bermahkota di singgasana'),
                                  Text('Bertaburkan kilau intan permata'),
                                  Text('Dan menyilaukan mata yang melihatnya'),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text('Semua terpesona padanya'),
                                  Text('Wajah nan jelita'),
                                  Text('Senyum manis ramah menggoda'),
                                  Text('Pada siapa saja, ha-ah'),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text('Namun sayang semuanya tak nyata'),
                                  Text('Kau hanyalah fatamorgana'),
                                  Text('Tak seindah tampaknya'),
                                  Text('Dan kau buat orang tergila-gila'),
                                  Text('Memuja lalu terpedaya'),
                                  Text('Tertipu sandiwara semu'),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text('Mudahnya kau mainkan logika'),
                                  Text('Semuanya tipu daya dan pura-pura'),
                                  Text('Tak kuasa ku pun ikut percaya'),
                                  Text('Terjerat janji surga terbawa suasana'),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _navIndex == 0;
    final headerTitle = switch (_navIndex) {
      0 => _greetingText(),
      1 => 'Playbox',
      2 => 'Library',
      _ => 'Profil',
    };

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: null,
      endDrawer: _navIndex == 1 ? _buildQueueDrawer() : null,
      body: Column(
        children: [
          // Sticky — di luar scroll, tetap di atas
          AppStickyHeader(title: headerTitle, onAvatarTap: () => _selectTab(3)),
          Expanded(
            child: switch (_navIndex) {
              0 => SpotifyHomePage(onOpenPlaybox: () => _selectTab(1)),
              1 => _buildMusicPlayboxBody(),
              2 => _buildLibraryBody(),
              _ => _buildProfileBody(),
            },
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHome)
            ValueListenableBuilder<bool>(
              valueListenable: _isPlaying,
              builder: (context, playing, _) {
                return SpotifyMiniPlayer(
                  isPlaying: playing,
                  position: _lyricPosition,
                  duration: _audioDuration,
                  onTogglePlay: _togglePlay,
                  onTap: () => _selectTab(1),
                );
              },
            ),
          BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: _selectTab,
            backgroundColor: AppTheme.bg,
            selectedItemColor: AppTheme.brand,
            unselectedItemColor: AppTheme.muted,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note_outlined),
                activeIcon: Icon(Icons.music_note),
                label: 'Playbox',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_outlined),
                activeIcon: Icon(Icons.library_music),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sapaan mengikuti jam WIB (UTC+7).
  String _greetingText() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = wib.hour;
    // Pagi 04–10 | Siang 11–14 | Sore 15–17 | Malam 18–03
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _buildQueueDrawer() {
    return Drawer(
      backgroundColor: AppTheme.bgMid,
      child: Container(
        color: AppTheme.bgMid,
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Queue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.muted),
                      tooltip: 'Tutup',
                    );
                  },
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PopupMenuButton<SampleItem>(
                        initialValue: selectedItem,
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 24,
                          color: Colors.white,
                        ),
                        onSelected: (SampleItem item) {
                          setState(() {
                            selectedItem = item;
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<SampleItem>>[
                              const PopupMenuItem<SampleItem>(
                                value: SampleItem.itemOne,
                                child: Text(
                                  'Add to Playlist',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const PopupMenuItem<SampleItem>(
                                value: SampleItem.itemTwo,
                                child: Text(
                                  'Save to liked songs',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const PopupMenuItem<SampleItem>(
                                value: SampleItem.itemThree,
                                child: Text(
                                  'Share',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/sandiwara_semu.jpg',
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sandiwara Semu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rumah Sakit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardLift,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/magnolia-celebration.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Magnolia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Magnolia Celebration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.play_circle,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/magnolia-celebration.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Magnolia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Magnolia Celebration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.play_circle,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/magnolia-celebration.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Magnolia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Magnolia Celebration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.play_circle,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/magnolia-celebration.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Magnolia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Magnolia Celebration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.play_circle,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPlayboxBody() {
    return Builder(
      builder: (context) {
        return AppTheme.page(
          safeTop: false,
          child: _FadeInOnMount(
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    Container(
                      width: 280,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.brandSoft.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/sandiwara_semu.jpg',
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sandiwara Semu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.text,
                            ),
                          ),
                          const Text(
                            'Rumah Sakit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.skip_previous_rounded,
                                size: 28,
                                color: AppTheme.muted,
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _togglePlay,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _isPlaying,
                                  builder: (context, playing, _) {
                                    return AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        playing
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_filled_rounded,
                                        key: ValueKey(playing),
                                        size: 44,
                                        color: AppTheme.brandSoft,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.skip_next_rounded,
                                size: 28,
                                color: AppTheme.muted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ValueListenableBuilder<Duration>(
                            valueListenable: _lyricPosition,
                            builder: (context, position, _) {
                              final active = lyricIndexAt(position);
                              final current = kSandiwaraLyrics[active].text;
                              final next = active + 1 < kSandiwaraLyrics.length
                                  ? kSandiwaraLyrics[active + 1].text
                                  : '';
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.brand,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Lyrics',
                                          style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 0.2,
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Material(
                                          color: Colors.white.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: InkWell(
                                            onTap: () =>
                                                _openLyricsFullscreen(context),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: const Tooltip(
                                              message: 'Fullscreen',
                                              child: SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: Icon(
                                                  Icons.open_in_full,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      child: Column(
                                        key: ValueKey(active),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            current,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.35,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (next.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              next,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1.3,
                                                color: Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.14),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            openBottomSheet(context),
                                        child: const Text(
                                          'See Detail',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                volume == 0
                                    ? Icons.volume_off_rounded
                                    : volume < 40
                                    ? Icons.volume_down_rounded
                                    : Icons.volume_up_rounded,
                                size: 20,
                                color: AppTheme.muted,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 10,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Slider(
                                    activeColor: AppTheme.brandSoft,
                                    inactiveColor: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    value: volume,
                                    min: 0,
                                    max: 100,
                                    padding: EdgeInsets.zero,
                                    onChanged: _setVolume,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: AppTheme.cardLift,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Next in Queue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.text,
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.text,
                                  backgroundColor: AppTheme.brand.withValues(
                                    alpha: 0.85,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () =>
                                    Scaffold.of(context).openEndDrawer(),
                                child: const Text(
                                  'Open Queue',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/magnolia-celebration.jpg',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Magnolia',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.text,
                                      ),
                                    ),
                                    Text(
                                      'Magnolia Celebration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLibraryBody() {
    final songs = [
      ('Sandiwara Semu', 'Rumah Sakit', 'assets/images/sandiwara_semu.jpg'),
      (
        'Magnolia',
        'Magnolia Celebration',
        'assets/images/magnolia-celebration.jpg',
      ),
      ('Liked Songs', 'Playlist', null),
      ('Indie Indo Mix', 'Radio', 'assets/images/sandiwara_semu.jpg'),
    ];

    return AppTheme.page(
      safeTop: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: songs.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 3,
                    height: 18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.brandSoft,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Koleksi kamu',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }
          final song = songs[index - 1];
          final image = song.$3;
          return Material(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              onTap: () => _selectTab(1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: image == null
                  ? Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [AppTheme.brand, Color(0xFFE8A0A0)],
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
              title: Text(
                song.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                ),
              ),
              subtitle: Text(
                song.$2,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              trailing: const Icon(
                Icons.play_circle_filled_rounded,
                color: AppTheme.brandSoft,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileBody() {
    return AppTheme.page(
      safeTop: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandSoft.withValues(alpha: 0.55),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.brand,
                child: Text(
                  'LA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Laksamana AryaPutra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '244107020021 · TI-3C',
              style: TextStyle(color: AppTheme.muted),
            ),
          ),
          const SizedBox(height: 28),

          const SizedBox(height: 14),
          _DemoLaunchCard(
            icon: Icons.photo_camera_outlined,
            title: 'Kamera & Galeri',
            subtitle: 'Preview kamera, ambil foto, simpan ke galeri',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppTheme.bg,
                    appBar: AppTheme.appBar('Demo Kamera'),
                    body: CameraHomePage(cameras: widget.cameras),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DemoLaunchCard(
            icon: Icons.map_outlined,
            title: 'Lokasi & Peta',
            subtitle: 'GPS, polygon Polinema & Kalm Coffee',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocationMapPage()),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.brandSoft.withValues(alpha: 0.2),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemrograman Mobile — Minggu 4',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Camera, Location, Map & Animation Widgets',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoLaunchCard extends StatelessWidget {
  const _DemoLaunchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.brand.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.brandSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fade-in saat widget baru masuk tree (mis. buka tab Playbox).
class _FadeInOnMount extends StatefulWidget {
  const _FadeInOnMount({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<_FadeInOnMount> createState() => _FadeInOnMountState();
}

class _FadeInOnMountState extends State<_FadeInOnMount> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: widget.child,
    );
  }
}
