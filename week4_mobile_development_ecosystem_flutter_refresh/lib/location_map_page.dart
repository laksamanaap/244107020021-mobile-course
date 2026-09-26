import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Zona spasial di peta (polygon + metadata).
class SpatialZone {
  const SpatialZone({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.center,
    required this.points,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String subtitle;
  final LatLng center;
  final List<LatLng> points;
  final Color color;
  final IconData icon;
}

/// Polygon bentuk acak/tidak beraturan di sekitar titik pusat.
/// [radii] = faktor jarak tiap sudut (urutan searah jarum jam dari utara).
List<LatLng> _irregularPolygon(
  LatLng center, {
  required double baseLat,
  required double baseLng,
  required List<double> radii,
}) {
  final n = radii.length;
  final points = <LatLng>[];
  for (var i = 0; i < n; i++) {
    // Mulai dari atas (-90° di atan2 lat/lng: lat = cos, lng = sin)
    final angle = -math.pi / 2 + (2 * math.pi * i / n);
    final r = radii[i];
    points.add(
      LatLng(
        center.latitude + math.cos(angle) * baseLat * r,
        center.longitude + math.sin(angle) * baseLng * r,
      ),
    );
  }
  return points;
}

/// Ray casting: apakah titik di dalam polygon?
bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].longitude;
    final yi = polygon[i].latitude;
    final xj = polygon[j].longitude;
    final yj = polygon[j].latitude;

    final intersect =
        ((yi > point.latitude) != (yj > point.latitude)) &&
        (point.longitude <
            (xj - xi) * (point.latitude - yi) / ((yj - yi) + 1e-12) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

final List<SpatialZone> kSpatialZones = [
  SpatialZone(
    id: 'polinema',
    name: 'Politeknik Negeri Malang',
    subtitle: 'Kawasan kampus Polinema',
    center: const LatLng(-7.946778, 112.615987),
    // Bentuk irregular ~9 sisi (seperti contoh)
    points: _irregularPolygon(
      const LatLng(-7.946778, 112.615987),
      baseLat: 0.0026,
      baseLng: 0.0030,
      radii: [1.05, 0.72, 1.18, 0.85, 1.10, 0.68, 1.22, 0.90, 0.78],
    ),
    color: const Color(0xFFB20000), // merah tua
    icon: Icons.school,
  ),
  SpatialZone(
    id: 'kalm_coffee',
    name: 'Kalm Coffee Daily',
    subtitle: 'Kalm Coffee Daily, Malang',
    center: const LatLng(-7.969418, 112.631275),
    // Bentuk irregular ~6 sisi
    points: _irregularPolygon(
      const LatLng(-7.969418, 112.631275),
      baseLat: 0.00085,
      baseLng: 0.00095,
      radii: [1.15, 0.75, 1.05, 0.70, 1.20, 0.82],
    ),
    color: const Color(0xFFFF6B6B), // merah terang
    icon: Icons.local_cafe,
  ),
];

/// Halaman peta + spatial polygon + overlay zona.
class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;

  Position? _position;
  SpatialZone? _currentZone;
  String? _error;
  String _status = 'Memulai...';
  bool _loading = true;
  bool _usedLastKnown = false;
  bool _showZoneOverlay = true;

  /// Kalau true, GPS update akan ikut geser kamera. Dimatikan saat user pan/zoom.
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  SpatialZone? _detectZone(LatLng point) {
    for (final zone in kSpatialZones) {
      if (_isPointInPolygon(point, zone.points)) return zone;
    }
    return null;
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = 'Cek GPS...';
      _followUser = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 5));
      if (!serviceEnabled) {
        _fail('GPS mati. Nyalakan Location di HP, lalu tekan Coba lagi.');
        return;
      }

      setState(() => _status = 'Cek izin lokasi...');
      var permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
      );

      if (permission == LocationPermission.denied) {
        setState(() => _status = 'Izinkan lokasi di dialog yang muncul...');
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 30),
        );
      }

      if (permission == LocationPermission.denied) {
        _fail('Izin lokasi ditolak.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _fail(
          'Izin lokasi diblokir permanen. Buka Settings > Apps > izin Lokasi.',
        );
        return;
      }

      setState(() => _status = 'Mencari lokasi...');
      final last = await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (last != null) {
        await _show(last, lastKnown: true);
      }

      await _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(locationSettings: _settings())
          .listen(
            (pos) => _show(pos, lastKnown: false),
            onError: (e) {
              debugPrint('position stream error: $e');
              if (_position == null && mounted) {
                _fail('Gagal GPS: $e');
              }
            },
          );

      unawaited(_fallbackCurrent());
    } on TimeoutException {
      _fail(
        'Timeout cek izin/GPS. Tutup app, nyalakan Location, lalu buka lagi.',
      );
    } catch (e) {
      _fail('Error lokasi: $e');
    }
  }

  Future<void> _fallbackCurrent() async {
    await Future<void>.delayed(const Duration(seconds: 12));
    if (!mounted || (_position != null && !_usedLastKnown)) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: _settings(),
      );
      await _show(pos, lastKnown: false);
    } catch (e) {
      debugPrint('fallback getCurrentPosition: $e');
      if (mounted && _position == null) {
        _fail(
          'GPS tidak merespons. Nyalakan Location mode High accuracy, lalu coba di luar ruangan.',
        );
      } else if (mounted) {
        setState(() {
          _loading = false;
          _status = 'Menampilkan lokasi terakhir';
        });
      }
    }
  }

  LocationSettings _settings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        forceLocationManager: false,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.high);
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  Future<void> _show(Position position, {required bool lastKnown}) async {
    if (!mounted) return;
    final point = LatLng(position.latitude, position.longitude);
    final zone = _detectZone(point);

    setState(() {
      _position = position;
      _currentZone = zone;
      _usedLastKnown = lastKnown;
      _loading = false;
      _error = null;
      if (zone != null) _showZoneOverlay = true;
      _status = lastKnown ? 'Lokasi terakhir' : 'Lokasi saat ini';
    });

    // Jangan paksa pindah kamera kalau user lagi eksplor peta
    if (!_followUser) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted || !_followUser) return;
    try {
      _mapController.move(point, _mapController.camera.zoom);
    } catch (_) {
      try {
        _mapController.move(point, 16);
      } catch (_) {}
    }
  }

  void _recenterToUser() {
    if (_position == null) {
      _followUser = true;
      _start();
      return;
    }
    setState(() => _followUser = true);
    try {
      _mapController.move(
        LatLng(_position!.latitude, _position!.longitude),
        16,
      );
    } catch (_) {}
  }

  void _flyToZone(SpatialZone zone) {
    // Loncat ke zona = mode eksplor, jangan ditarik balik GPS
    setState(() => _followUser = false);
    try {
      _mapController.move(zone.center, 16);
    } catch (_) {}
  }

  double _distanceToZoneMeters(SpatialZone zone) {
    if (_position == null) return double.infinity;
    return Geolocator.distanceBetween(
      _position!.latitude,
      _position!.longitude,
      zone.center.latitude,
      zone.center.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _position == null
        ? const LatLng(-7.9666, 112.6326)
        : LatLng(_position!.latitude, _position!.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 161, 29, 29),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                // User geser/zoom → stop auto-follow GPS
                if (hasGesture && _followUser && mounted) {
                  setState(() => _followUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.week4_mobile_development_ecosystem_flutter_refresh',
              ),
              PolygonLayer(
                polygons: [
                  for (final zone in kSpatialZones)
                    Polygon(
                      points: zone.points,
                      color: zone.color.withValues(alpha: 0.25),
                      borderColor: zone.color,
                      borderStrokeWidth: 2.5,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final zone in kSpatialZones)
                    Marker(
                      point: zone.center,
                      width: 120,
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(zone.icon, color: zone.color, size: 22),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: zone.color),
                            ),
                            child: Text(
                              zone.id == 'polinema' ? 'Polinema' : 'Kalm',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: zone.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_position != null)
                    Marker(
                      point: LatLng(_position!.latitude, _position!.longitude),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 161, 29, 29),
                        size: 48,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // AnimatedOpacity: fade in/out overlay zona
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: AnimatedOpacity(
              opacity: (_currentZone != null && _showZoneOverlay && !_loading)
                  ? 1
                  : 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring:
                    !(_currentZone != null && _showZoneOverlay && !_loading),
                child: _currentZone == null
                    ? const SizedBox.shrink()
                    : Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(14),
                        color: _currentZone!.color,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _flyToZone(_currentZone!),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _currentZone!.icon,
                                    color: _currentZone!.color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Column(
                                      key: ValueKey(_currentZone!.id),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Kamu berada di kawasan',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _currentZone!.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _currentZone!.subtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _showZoneOverlay = false);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Tutup',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Chip cepat loncat ke zona
          if (!_loading)
            Positioned(
              left: 16,
              right: 16,
              top: _currentZone != null && _showZoneOverlay ? 96 : 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final zone in kSpatialZones) ...[
                        ActionChip(
                          avatar: Icon(zone.icon, color: zone.color, size: 18),
                          label: Text(
                            zone.id == 'polinema' ? 'Polinema' : 'Kalm',
                          ),
                          onPressed: () => _flyToZone(zone),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: zone.color),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          if (_loading)
            ColoredBox(
              color: const Color(0x88000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _status,
                        key: ValueKey(_status),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (_currentZone?.color ?? Colors.black).withValues(
                      alpha: _currentZone != null ? 0.35 : 0.12,
                    ),
                    blurRadius: _currentZone != null ? 12 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _error != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: Geolocator.openLocationSettings,
                                  child: const Text('GPS Settings'),
                                ),
                                TextButton(
                                  onPressed: Geolocator.openAppSettings,
                                  child: const Text('App Settings'),
                                ),
                                TextButton(
                                  onPressed: _start,
                                  child: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _status,
                                      key: ValueKey(_status),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_position == null)
                                    const Text('Belum ada koordinat')
                                  else ...[
                                    Text(
                                      'Latitude  : ${_position!.latitude.toStringAsFixed(6)}',
                                    ),
                                    Text(
                                      'Longitude : ${_position!.longitude.toStringAsFixed(6)}',
                                    ),
                                    Text(
                                      'Akurasi   : ±${_position!.accuracy.toStringAsFixed(1)} m',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AnimatedOpacity(
                                      opacity: _currentZone != null ? 1 : 0.85,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: _currentZone != null
                                          ? Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _currentZone!.color
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _currentZone!.color,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _currentZone!.color,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Di dalam polygon: ${_currentZone!.name}',
                                                      style: TextStyle(
                                                        color:
                                                            _currentZone!.color,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!_showZoneOverlay)
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(
                                                          () =>
                                                              _showZoneOverlay =
                                                                  true,
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Overlay',
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          : Text(
                                              'Di luar kawasan Polinema & Kalm Coffee'
                                              '${_nearestZoneHint()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tombol current location di dalam kartu
                            Hero(
                              tag: 'location_hero',
                              child: Material(
                                color: const Color.fromARGB(255, 161, 29, 29),
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: _recenterToUser,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Tooltip(
                                    message: 'Kembali ke lokasiku',
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Icon(
                                        _followUser
                                            ? Icons.my_location
                                            : Icons.location_searching,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _nearestZoneHint() {
    if (_position == null) return '';
    SpatialZone? nearest;
    var best = double.infinity;
    for (final zone in kSpatialZones) {
      final d = _distanceToZoneMeters(zone);
      if (d < best) {
        best = d;
        nearest = zone;
      }
    }
    if (nearest == null || !best.isFinite) return '';
    final meters = best.round();
    final label = nearest.id == 'polinema' ? 'Polinema' : 'Kalm';
    return ' · ±$meters m ke $label';
  }
}
