import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'location_map_page.dart';

/// Halaman Home: preview kamera, selfie, ambil foto, dan simpan.
class CameraHomePage extends StatefulWidget {
  const CameraHomePage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<CameraHomePage> createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _imagePath;
  String? _savedPath;
  String? _error;
  int _cameraIndex = 0;
  bool _isSaving = false;

  bool get _hasFrontCamera =>
      widget.cameras.any((c) => c.lensDirection == CameraLensDirection.front);

  bool get _isSelfie {
    if (widget.cameras.isEmpty) return false;
    return widget.cameras[_cameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pickInitialCamera();
    _initCamera();
  }

  void _pickInitialCamera() {
    if (widget.cameras.isEmpty) return;
    final backIndex = widget.cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    _cameraIndex = backIndex >= 0 ? backIndex : 0;
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() {
        _error = 'Kamera tidak tersedia di perangkat ini.';
      });
      return;
    }

    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    final camera = widget.cameras[_cameraIndex];
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _controller = controller;
    _initializeControllerFuture = controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _error = null;
          });
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() {
            _error = 'Gagal membuka kamera: $e';
          });
        });

    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya ada satu kamera di perangkat ini')),
      );
      return;
    }

    // Prefer toggle back <-> front
    final current = widget.cameras[_cameraIndex].lensDirection;
    final target = current == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    var nextIndex = widget.cameras.indexWhere((c) => c.lensDirection == target);
    if (nextIndex < 0) {
      nextIndex = (_cameraIndex + 1) % widget.cameras.length;
    }

    setState(() {
      _cameraIndex = nextIndex;
      _imagePath = null;
      _savedPath = null;
    });
    await _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      if (state == AppLifecycleState.resumed) {
        _initCamera();
      }
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    final initFuture = _initializeControllerFuture;
    if (controller == null || initFuture == null) return;

    try {
      await initFuture;
      if (!controller.value.isInitialized) return;

      final image = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _imagePath = image.path;
        _savedPath = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Future<void> _savePicture() async {
    if (_imagePath == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      // Minta izin akses galeri (Android lama / iOS)
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin galeri ditolak. Aktifkan di Settings.'),
            ),
          );
          return;
        }
      }

      // Salin dulu ke file permanen, lalu masukkan ke Galeri
      final docsDir = await getTemporaryDirectory();
      final fileName =
          'foto_${DateTime.now().millisecondsSinceEpoch}${_isSelfie ? '_selfie' : ''}.jpg';
      final tempPath = p.join(docsDir.path, fileName);
      await File(_imagePath!).copy(tempPath);

      await Gal.putImage(tempPath, album: 'Music Playbox');

      if (!mounted) return;
      setState(() {
        _savedPath = 'Galeri / Music Playbox';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto berhasil disimpan ke Galeri (album Music Playbox)',
          ),
        ),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan ke galeri: ${e.type.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan foto: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    final initFuture = _initializeControllerFuture;
    final controller = _controller;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (initFuture == null || controller == null)
                const Center(child: CircularProgressIndicator())
              else
                FutureBuilder<void>(
                  future: initFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        controller.value.isInitialized) {
                      Widget preview = CameraPreview(controller);
                      // Mirror preview saat selfie biar natural
                      if (_isSelfie) {
                        preview = Transform.scale(scaleX: -1, child: preview);
                      }
                      return preview;
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'switch_camera',
                      onPressed: _hasFrontCamera || widget.cameras.length > 1
                          ? _switchCamera
                          : null,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        _isSelfie ? Icons.camera_rear : Icons.cameraswitch,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isSelfie ? 'Selfie' : 'Belakang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                // Hero antar halaman: Home → Peta
                heroTag: 'location_hero',
                onPressed: () async {
                  final navigator = Navigator.of(context);

                  // Pause kamera supaya tidak bentrok resource saat buka peta
                  final previous = _controller;
                  _controller = null;
                  _initializeControllerFuture = null;
                  await previous?.dispose();
                  if (!mounted) return;
                  setState(() {});

                  await navigator.push(
                    MaterialPageRoute(builder: (_) => const LocationMapPage()),
                  );

                  if (!mounted) return;
                  await _initCamera();
                },
                backgroundColor: const Color.fromARGB(255, 161, 29, 29),
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'take_picture',
                onPressed: _takePicture,
                backgroundColor: const Color.fromARGB(255, 161, 29, 29),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              const SizedBox(width: 16),
              FloatingActionButton.extended(
                heroTag: 'save_picture',
                onPressed: _imagePath == null || _isSaving
                    ? null
                    : _savePicture,
                backgroundColor: _imagePath == null
                    ? Colors.grey
                    : const Color.fromARGB(255, 46, 125, 50),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _savedPath != null ? 'Tersimpan' : 'Simpan',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(12),
            child: _imagePath == null
                ? Center(
                    child: Text(
                      'Preview foto akan muncul di sini',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hasil foto',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const Spacer(),
                          if (_savedPath != null)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (_savedPath != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _savedPath!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
