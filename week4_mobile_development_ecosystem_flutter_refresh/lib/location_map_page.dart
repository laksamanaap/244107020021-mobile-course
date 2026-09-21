import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Halaman peta (OpenStreetMap) + pin lokasi saat ini.
class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;

  Position? _position;
  String? _error;
  String _status = 'Memulai...';
  bool _loading = true;
  bool _usedLastKnown = false;

  @override
  void initState() {
    super.initState();
    // Tunggu frame pertama supaya dialog izin bisa muncul di atas halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = 'Cek GPS...';
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

      // Stream lebih andal daripada getCurrentPosition di Samsung
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

      // Safety: kalau stream diam 12 detik, coba getCurrentPosition sekali
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
    setState(() {
      _position = position;
      _usedLastKnown = lastKnown;
      _loading = false;
      _error = null;
      _status = lastKnown ? 'Lokasi terakhir' : 'Lokasi saat ini';
    });

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    try {
      _mapController.move(LatLng(position.latitude, position.longitude), 16);
    } catch (_) {}
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
        actions: [
          IconButton(
            onPressed: _start,
            icon: const Icon(Icons.my_location),
            tooltip: 'Refresh lokasi',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: center, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.week4_mobile_development_ecosystem_flutter_refresh',
              ),
              if (_position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _position!.latitude,
                        _position!.longitude,
                      ),
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
          if (_loading)
            ColoredBox(
              color: const Color(0x88000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
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
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _status,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
