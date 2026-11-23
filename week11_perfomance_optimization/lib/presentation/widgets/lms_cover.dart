import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Gambar daftar/grid.
/// Aset didekode seukuran tampilan (`cacheWidth`/`cacheHeight`).
/// URL memakai `CachedNetworkImage` + `memCacheWidth` supaya bitmap
/// di memori tidak sebesar file aslinya.
class LmsCover extends StatelessWidget {
  const LmsCover({
    super.key,
    this.asset,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? asset;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final logicalW = (width != null && width!.isFinite)
        ? width!
        : MediaQuery.sizeOf(context).width;
    final cacheW = (logicalW * dpr).round().clamp(1, 2048);
    final cacheH = (height != null && height!.isFinite)
        ? (height! * dpr).round().clamp(1, 2048)
        : null;

    final url = imageUrl;
    final Widget image;
    if (url != null && url.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheW,
        memCacheHeight: cacheH,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, _) => const ColoredBox(color: AppTheme.bgMid),
        errorWidget: (context, _, _) => _asset(cacheW, cacheH),
      );
    } else {
      image = _asset(cacheW, cacheH);
    }

    return RepaintBoundary(child: image);
  }

  Widget _asset(int cacheW, int? cacheH) {
    final path = asset;
    if (path == null || path.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: AppTheme.bgMid,
          child: Icon(Icons.image_outlined, color: AppTheme.muted),
        ),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheW,
      cacheHeight: cacheH,
    );
  }
}
